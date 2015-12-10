# Prototype Environments

The prototype is deployed at Amazon Web Services (AWS). It is deployed in 3 different environments. Each environment represents a stage in the development life-cycle. There is also a Continuous Integration (CI) web tool that supports the life-cycle.

* [Integration environment](http://gsa-ads-2-elbwebex-1l78v7v6k7szj-2091903140.us-east-1.elb.amazonaws.com/) - Developers deploy new changes here first and test them (in combination with changes of potential other developers)
* [Test environment](http://gsa-ads-2-elbwebex-15wqptfab7c7o-1537924130.us-east-1.elb.amazonaws.com/) - When there is enough critical mass of changes that constitute what the stakeholders consider a new version of the web application, the changes made are deployed here. Testers will use this environment to verify these changes meet the requirements.
* [Production environment](http://gsa-ads-2-elbwebex-8jb6jmg989jy-1215229994.us-east-1.elb.amazonaws.com/) - This is the live environment. Once a the changes deployed in the Test environment pass the test criteria, that version is released (deployed) to this environment.
* [Continuous Integration](http://54.174.243.195/) - This shows the status of deployments to various environments.


