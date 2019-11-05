---
layout: post
title: Continuous Integration for Mobile Apps with AppThwack and Jenkins
date: 2013-09-03 13:51:00-8000
author: me
category: writings
tags: [appthwack, jenkins, archive, announcement]
---
![](/assets/images/posts/jenkins-appthwack-header.png)

Today, were happy to announce the initial release of our [Jenkins](https://jenkins.io/) plugin, which introduces AppThwack into your [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration) cycle.[^part-2]

[^part-2]: {-}
   This is part one of a blog post series about continuous integration for mobile apps.
   Be sure to check out [Part 2]({% post_url /2014-05-02-continuous-integration-for-mobile-apps-appthwack-jenkins-part-2 %}) for more advanced plugin features such as results integration and performance graphs.

As developers ourselves, we understand the importance of seamless tool integrations within the development workflow.
Last week we announced the release of our [Android Studio/Gradle]({% post_url /2013-08-28-android-app-testing-android-studio-gradle %}) plugin,
which enables testing of Android apps on hundreds of devices directly from your IDE.

Ready to get started? Here's a quick tutorial to get started with [AppThwack](http://web.archive.org/web/20140929012749/https://appthwack.com),
[Jenkins](https://jenkins.io/) and [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration) for mobile apps.
Once you're up and running, you'll be able to kick off tests on our [device lab](http://web.archive.org/web/20140929012749/https://appthwack.com/devicelab) from your own Jenkins server!

## Installation

The AppThwack plugin lives in the official Jenkins-CI maven repository. That means you can download/install it directly from within your running Jenkins server.

Starting at the Jenkins homepage, navigate to the **Manage Jenkins > Manage Plugins** page.

[^plugin-select] From the plugin view, click the **Available** tab and scroll to find the AppThwack plugin.

[^plugin-select]: {-}
   ![Plugin Select](/assets/images/posts/jenkins-appthwack-plugin-select.png)

Finally, scroll to the bottom and click **Install**.

## System Settings

Navigate to **Manage Jenkins > Configure System**.

Scroll down to the *AppThwack* settings section to add your [API Key](https://web-beta.archive.org/web/20150303112303/https://appthwack.com/user/profile).[^api-key] This key is used to authenticate your Jenkins server with AppThwack and is used across all of your Jenkins projects.

[^api-key]: {-}
   ![API Key](/assets/images/posts/jenkins-appthwack-api-key.png)

Now that your API key added, its time to navigate to a Jenkins project and configure the post-build action.

## Project Settings

Navigate to a project of your choice and click **Configure** button from the left-hand side menu.

### Add Post-build action

 [^post-build-action] Click the *Add post-build action* button, select **Run Tests on AppThwack** and you'll notice a new,
AppThwack specific settings section appear. All remaining configuration will happen here.

[^post-build-action]: {-}
   ![Post Build Action](/assets/images/posts/jenkins-appthwack-action.png)

### Choose your Project and Device Pool

[^settings] First up is selecting your AppThwack project and selecting which devices to test on.

[^settings]: {-}
   ![Settings](/assets/images/posts/jenkins-appthwack-settings-fields.png)

### Find your Application

Next up is configuring the plugin to find your newly built mobile app.
The application field allows for standard Jenkins (ant) [pattern matching](http://stackoverflow.com/questions/69835/how-do-i-use-nant-ant-naming-patterns) with
expandable [environment variables](https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project#Buildingasoftwareproject-JenkinsSetEnvironmentVariables).
Please note that this pattern is relative to the Jenkins **workspace** currently being used by the project/build.

## Test Settings

The next step is selecting which tests you wish to run. If you dont have custom tests written for your app (yet), you can still run the AppThwack built-in compatibility test suites.
These suites will Install, Launch, Explore and Stress your app with no code changes necessary.

Lets walk-through configuring some tests for both Android and iOS.

### Built-in Test Suites

[^built-in-android] AppThwack provides a built-in compatibility test suite for both Android and iOS.

 The built-in Android test suite supports additional options for configuring our AppExplorer. These are *optional* and should configured on a case-by-case basis.

[^built-in-android]: {-}
   ![Built-in Android](/assets/images/posts/jenkins-appthwack-builtin-android.png)

### Calabash

[^calabash] You can run your custom [Calabash](http://calaba.sh/) scripts for both Android and iOS.
Please note that the features field supports the same pattern matching and environment variables as the application one above.

[^calabash]: {-}
   ![Calabash](/assets/images/posts/jenkins-appthwack-calabash.png)

### JUnit/Robotium

[^junit] Have a JUnit/Robotium project building with your app? Same pattern matching rules apply.

[^junit]: {-}
   ![JUnit](/assets/images/posts/jenkins-appthwack-junit.png)

### KIF

[^kif] Functional tests on iOS with KIF are supported too; no configuration required

[^kif]: {-}
   ![KIF](/assets/images/posts/jenkins-appthwack-kif.png)

### UIA

[^uia] Last, but certainly not least, iOS UI Automation. Same pattern rules apply for finding your Javascript tests.

[^uia]: {-}
   ![UIA](/assets/images/posts/jenkins-appthwack-uia.png)

Click *Save* as the configuration is complete!

## Build/Test

To manually kick off a build from a Jenkins project, click the **Build Now** button from the left-side menu.

Once your app builds successfully, an examination of the Console Output will yield the following:

<figure class="fullwidth">
```bash
...
[AppThwack] Using Project 'demoproject-ios'
[AppThwack] Using DevicePool 'hawker-test-pool-ios'
[AppThwack] Archiving artifact 'IOSTestApp.ipa'
[AppThwack] Using App '/home/ahawker/src/appthwack-jenkins/work/jobs/test/builds/2013-08-30_17-54-09/archive/IOSTestApp.ipa'
[AppThwack] Archiving artifact 'calabash.zip'
[AppThwack] Using 'calabash' test content from '/home/ahawker/src/appthwack-jenkins/work/jobs/test/builds/2013-08-30_17-54-09/archive/calabash.zip'
[AppThwack] Scheduling 'calabash' run 'IOSTestApp.ipa (Jenkins)'
[AppThwack] Congrats! See your test run at https://appthwack.com/project/demoproject-ios/run/24549
Finished: SUCCESS
```
</figure>

You're done! You can now schedule tests on AppThwack from your own Jenkins Continuous Integration server!

Using the AppThwack Jenkins plugin (or any of our tools) in your development process? Let us know! Wed love to hear success stories and feedback about how we can improve our integration into your workflow.

Having a problem or want to contribute? The plugin is open source! Check out the Github page for more details! [^archived]

[^archived]: {-}
  This post was migrated from the [AppThwack Blog](https://blog.appthwack.com) which is no longer available.
  A copy of the original post can be viewed from [archive.org](https://web-beta.archive.org/web/20150303112303/http://blog.appthwack.com:80/continuous-integration-for-mobile-apps/).
