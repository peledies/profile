from jira import JIRA

from jirasettings import USER, JIRA_KEY

class JiraReporting():
    def __init__(self, user=USER, jiraKey=JIRA_KEY):
        self.options = {
            'server': 'https://dtnse1.atlassian.net'
        }
        self.projectName = "Agronomic Platform (AP)"
        self.labels = [
            'Web',
            'iOS',
            'Android'
        ]

        self.jira = JIRA(self.options, basic_auth=(user, jiraKey))

    def printTaskStatus(self):

        # Loop through labels
        for label in self.labels:
            # print(label.center(30, '-'))
            # Header 1
            print('# {}'.format(label))
            # Horizontal rule
            print('---')

            # Find all issues in the current sprint for our project with this label
            issues = self.jira.search_issues(
                f'Sprint in openSprints() AND project="{self.projectName}" and type in '
                f'standardIssueTypes() and labels = {label}',
                maxResults=False
            )
            # Loop through the issues
            for issue in issues:
                # print(issue.key, issue.fields.summary)
                # Header 3
                print('### {}'.format(issue.key))
                # Quote-block
                print('> [{}] {}'.format(
                    issue.fields.issuetype.name,
                    issue.fields.summary
                ))
                # Grab the subtasks
                for subtask in issue.fields.subtasks:
                    # Bullet points
                    print("*", '[{}]'.format(subtask.fields.status.name),
                          subtask.key, subtask.fields.summary)

    def printNoAccounts(self):
        # Loop through labels
        for label in self.labels:
            # Find all issues in the current sprint for our project with this label
            issues = self.jira.search_issues(
                f'Sprint in openSprints() AND project="{self.projectName}" and type in '
                f'standardIssueTypes() and labels = {label}',
                maxResults=False
            )

            print(f"-----{label}-----")
            noAccountIssues = []
            noAccountSubtasks = []
            # Loop through the issues
            for issue in issues:
                if issue.fields.customfield_14101 is None:
                    noAccountIssues.append(issue.key)
                # Grab the subtasks
                for subtaskIssue in self.getSubtasksAsIssues(issue):
                    if subtaskIssue.fields.customfield_14101 is None:
                        noAccountSubtasks.append(subtaskIssue.key)

            noAccounts = noAccountIssues + noAccountSubtasks
            if noAccounts:
                print("Missing accounts linked to these tickets:")
                for noAccount in noAccounts:
                    print(noAccount)
            else:
                print("All tickets have an account linked")

    def getSubtasksAsIssues(self, parentIssue):
        # Grab the subtasks
        subtaskIds = []
        for subtask in parentIssue.fields.subtasks:
            subtaskIds.append(subtask.key)
        if subtaskIds:
            subtaskIds = [f'\"{value}\"' for value in subtaskIds]
            subtaskIds = ', '.join(subtaskIds)
            return self.jira.search_issues(
                f"key in ({subtaskIds})",
                maxResults=False
            )
        else:
            return []

print("Select a report")
print("1: Task status report")
print("2: Tasks with no accounts")

selection = int(input("Selection: "))

jr = JiraReporting()
if selection == 1:
    jr.printTaskStatus()
elif selection == 2:
    jr.printNoAccounts()
