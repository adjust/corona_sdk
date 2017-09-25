package com.yourcompany;

import org.apache.log4j.Logger;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;
import org.junit.runner.RunWith;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.testobject.appium.junit.TestObjectTestResultWatcher;
import org.testobject.rest.api.appium.common.TestObject;
import org.testobject.appium.junit.TestObjectAppiumSuite;
import io.appium.java_client.android.AndroidDriver;
import java.net.URL;
import java.util.List;
import org.openqa.selenium.OutputType;

@TestObject(testObjectApiKey = "D700B87EB6474CC59C211A47F32AA252", testObjectSuiteId = 7)
@RunWith(TestObjectAppiumSuite.class)
public class TestOne{
    public static String PACKAGE_NAME = "com.example.testapp";
    @Rule
    public TestName testName = new TestName();

    @Rule
    public TestObjectTestResultWatcher resultWatcher = new TestObjectTestResultWatcher();

    private AndroidDriver driver;
    private static Logger log = Logger.getLogger(TestOne.class);

    @Before
    public void setUp() throws Exception {
        DesiredCapabilities capabilities = new DesiredCapabilities();

        capabilities.setCapability("testobject_api_key", resultWatcher.getApiKey());
        capabilities.setCapability("testobject_test_report_id", resultWatcher.getTestReportId());

        driver = new AndroidDriver(new URL("https://eu1.appium.testobject.com/wd/hub"), capabilities);

        resultWatcher.setAppiumDriver(driver);

        log.info(testName.getMethodName() + " STARTING - Live view: " + driver.getCapabilities().getCapability("testobject_test_live_view_url"));

    }

    @After
    public void tearDown() {
        log.info(testName.getMethodName() + " ENDING - Test report: " + driver.getCapabilities().getCapability("testobject_test_report_url"));
    }

    @Test
    public void testMethod() {
        System.out.println("Testing...");

        //Initial delay
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println("passed initial delay");

        while (true) {
            boolean isRunning = driver.getPageSource().contains(TestOne.PACKAGE_NAME);

            if (!isRunning) {
                System.out.println("Test concluded...");
                break;
            } else {
                System.out.println("still testing...");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
