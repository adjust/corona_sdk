## Java-JUnit-Appium-Android-Suite

>This code is presented as an example only, since your tests and testing environments may require specialized scripting. This information should be taken only as an
>illustration of how one would set up tests with Sauce Labs, and any modifications will not be supported. For questions regarding Sauce Labs integration, please see 
>our documentation at https://wiki.saucelabs.com/.

### Environment Setup

1. Global Dependencies
    * Install Maven
    	https://maven.apache.org/install.html
    * Or Install Maven with Homebrew
    	http://brew.sh/
    ```
    $ brew install maven
    ```
2. TestObject Environment Variables
    * export TESTOBJECT_API_KEY=<your project's API key>
    ```
    * export TESTOBJECT_SUITE_ID=<your targeted suite's ID>

3. Project Dependencies
    * Check that packages are available
    ```
    $ cd Java-JUnit-Appium-Android-Suite
    $ mvn test-compile
    ```
    * You may also want to run the command below to check for outdated dependencies. Please be sure to verify and review updates before editing your pom.xml file as they may not be compatible with your code.
    ```
    $ mvn versions:display-dependency-updates
    ```
4. Application
    * Application can be downloaded by clicking [here](http://saucelabs.com/example_files/ContactManager.apk)
    
### Running Tests
	* Note: Suite must be created and devices selected before running tests.

#####Execute Suite:
```
$ mvn test
```

### Advice/Troubleshooting
1. It may be useful to use a Java IDE such as IntelliJ or Eclipse to help troubleshoot potential issues. 

### Resources
##### [TestObject Suite Documentation](https://help.testobject.com/docs/tools/appium/setups/suite-setup/junit/)

##### [Sauce Labs Documentation](https://wiki.saucelabs.com/)

##### [Junit Documentation](http://junit.org/javadoc/latest/index.html)

##### [Java Documentation](https://docs.oracle.com/javase/7/docs/api/)

##### [Stack Overflow](http://stackoverflow.com/)
* A great resource to search for issues not explicitly covered by documentation.








