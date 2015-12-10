1. A User Story or Defect is assigned to a Developer.

2. The Developer takes the following steps to implement the User Story of fix the Defect
    1. Create (or use an existing) local git clone of the integration branch on her local computer.
    2. Change PHP, CSS and/or JavaScript code checked-out from the local git-clone. 
    3. Tests these changes on her local system.

3. Once the Developer completes her testing, she:
    1. Commits code to her local git-clone providing the User Story Id in the commit description code to link the changes to the User Story
    2. Pushes her local commits to the GitHub integration branch

4. Once one (1) or more developers have committed changes, the Jenkins "Deploy to Integration" job on the Continuous Integration host pulls the code from the GitHub integration branch and:
    1. Runs all unit tests
    2. If any test fails, changes must be made to fix the issue. The process returns to step 1.
    3. If all tests succeed, the job deploys the changes into the hosted Integration environment.

5. The Developers that have committed changes verify their changes in the hosted Integration environment (where the changes are now deployed).
    1. If a defect is found, the developer will need to make the necessary changes, and the process returns to step 1.
    2. If the changes work as expected, the Developers mark the associated User Story as "Resolved".

6. Once (a significant subset of) the changes for the next planned release have been made and tested in the hosted Integration environment, a DevOps engineer merges all of the changed associated with "Resolved" stories from the integration branch into the test branch to create a new Release Candidate.

6. Once all testing of the previous Release Candidate has been completed, the DevOps engineer now triggers the "Deploy to Test" job in Jenkins. This pulls the code from the GitHub test branch, and:
    1. Runs all unit tests
    2. If any test fails, changes must be made to fix the issue. The process returns to step 1.
    3. If all tests succeed, the job deploys the changes into the hosted Test environment.

7. The User Stories associated with User Stories marked as "Resolved" now deployed in the hosted Test environment are assigned to Testers.

8. Testers perform all Test Cases linked to the User Story.
    1. If the test steps of any Test Case fail  in any way, the Tester creates a Bug and links it to the Test Case
    2. If the test steps succeed, the Tester marks the User Story as "Closed"

9. Any new Bug is evaluated, the Bug is assigned to a Developer and the process returns to step 1.

10. Once all User Stories planned for the release in the current sprint are marked as "Closed", a DevOps engineer merges all of the changed associated with "Closed" stories from the test branch into the master branch to create a new Release.

11. The DevOps engineer now triggers the "Deploy to Production" job in Jenkins. This pulls the code from the GitHub master branch that now contains all changes for the new releases, and deploys the changes to the hosted Production environment.


