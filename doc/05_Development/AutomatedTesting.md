# Introduction

Automated testing occurs in two ways:

1. **Integration Tests** - These are [Selenium](http://www.seleniumhq.org/) tests that run tests against the deployed application. These are tester oriented test cases.
2. **Unit Tests** - These are [PHPUnit](https://phpunit.de/) tests that test the application's PHP code at the code level. These are programmer-oriented test cases.

Both types of tests can be run locally by Testers and Developers. The Tests can also be run in a headless (without an actual browser) fashion on the Continuous Integration server in the Jenkins application. The PHP unit tests are automatically run as part of the deployment process, while Selenium tests must be manually triggered.

# Selenium Tests

## How to Run Selenium Tests Locally

1. Download the [Selenium Server](https://github.com/Aquilent/drug-adverse-event-browser/blob/integration/src/main/chef/chef-repo/cookbooks/gsa_ads/files/default/bastion/selenium-server-standalone-.46.0.jar?raw=true)
2. Start the server from a Windows Prompt in the directory where you downloaded the Selenium Server into
   1. Open Windows File Explorer; Browse to the parent directory of the directory where the jar file is stored; Right-click the directory while Holding down the shift-key; Select "Open command window here ..."
   2. Open a Command Prompt; change directory to where you down loaded the server (`cd /path/to/directory`)
4. Run the following command: `java -jar selenium-server-standalone-2.46.0.jar`
   This assumes Java is installed and is on your windows PATH. If it is not in your PATH, replace java with `/path/to/directory/where/java_is_installed/bin/java`
5. Start Firefox
6. If not yet installed. Install the [Selenium plugin](http://www.seleniumhq.org/projects/ide/)
7. Open the Selenium plugin (Find the Selenium button on the add-on toolbar)
8. Open a selenium test case  via `File > Open`. Test cases can be found in the code under `src/test/selenium/test-cases`
9. Select the environment against which to run the test case by replacing the Base URL. By default it uses the Integration environment.
10. Make sure the Firefox webdriver is used  via `Options > Options > Webdriver`
11. Execute the test cases in the Selenium plug-in via `Actions > Play the current test case`
12. Selenium will open a new Firefox window run through the various steps in the test case 

## How to Selenium Tests are Run as Part of Continuous Integration

1. Using the Selenium plugin, export each test case to as a "Python 2 / Unit Test / Web Driver" file as store the file in the `src/test/selenium/test-scripts` directory in a local git clone of the integration branch.
2. Commit the changes locally and then push them to the integration branch
3. The next time the "Run Selenium Tests at Integration" [Jenkins](http://54.174.243.195/) job is run, all tests are automatically executed:
  1. The Jenkins jobs calls a script that creates a local git clone of the integration branch
  2. Modifies the test scripts to use the PhantomJS drive (for headless testing), ensure the test runs against the integration environment by replacing the base-url, and replaces the unit runner to ensure it outputs a JUnit XML report that Jenkins can consume
  3. Runs the modified Python scripts writing the report to a designated directory
  4. It interprets the JUnit XML report to [show the results](https://wiki.jenkins-ci.org/display/JENKINS/JUnit+Plugin) of the test in Jenkins
4. Once new code and tests get merged from the integration branch into the test branch, and the Jenkins job "Run Selenium Tests at Test" is run, a git-clone of the test branch is made and the tests are run against the test environment.


# PHP Unit Tests

## Running PHP Unit Tests Locally

1. Create an environment in which PHPUnit can be run
  1. Install [PHP](http://php.net/manual/en/install.windows.php) and [Composer](https://getcomposer.org/download/) (includes PHPUnit), locally on your development system.
  2. [Deploy the system locally in a Virtual Box virtual machine using Vagrant](https://github.com/Aquilent/drug-adverse-event-browser/wiki/Running-the-Prototype-Locally). The following assumes you are using this option.
2. Use vagrant ssh to log into the virtual machine.
3. Run `sudo /var/www/gsa-ads/vendor/phpunit/phpunit/phpunit/ --bootstrap /var/www/gsa-ads/vendor/autoload.php /var/www/gsa-ads/tests/`
4. Review your test results

## How PHP Unit Tests are Run as Part of Continuous Integration

For each environment (Integration, Test, Production) there is a "Deploy to _environment_" [Jenkins](http://54.174.243.195/) Jobs that will:

1. Run a script that:
  1. Creates a local git-clone of the environment's branch (integration : integration, test: test, production: master) on the Jenkins system
  2. Runs the commands as shown above (in the "Running PHP Unit Tests Locally" section) against the local git-clone on the Jenkins system. It will add a command-line option to generate a JUnit XML report to be stored in a location accessible by Jenkins.
  3. If all tests pass, the script will deploy the code to the server of the environment. If any of the tests fail, no code will be deployed.
2. As a post-execution-action the Jenkins job will interpret the test output to show results in the Jenkins application.
