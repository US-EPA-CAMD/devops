# CAMD Runbook #

The CAMD runbook serves to provide detailed documentation and  instructions  for the CAMD Applications frequently utilized solutions, processes and procedures. 

## Table of Contents: 
<ol> 
	<li> [API Gateway](#api)
		<ol>
		<li>[Confirguration](#apiConfig)
		<li>[Troubleshooting](#apiTrouble)
		</ol>
	<li>[CORS Policy Administration](#cors)
		<ol>
		<li>[Adding/Removing CORS policy](#corsPolicy)
		<li>[Troubleshooting](#corsTrouble)
		</ol>
	<li>[Data Migration](#data)
		<ol>
		<li>[Change data capture](#dataCapture)
		<li>[Job timing](#dataJob)
		<li>[Troubleshooting](#dataTrouble)
		</ol>
		<li> [Quartz Job Scheduler](#quartz)
	<ol>
		<li> [Bulk Data Files](#quartzBulk)
		<li>[Check Engine](#quartzCheck)
		<li>[Troubleshooting](#quartzTrouble)
		</ol>
		<li> [Cloud.gov ](#cloud)
		<ol>
		<li> [Managing app resources (memory, instances)](#cloudManage)
		<li> [Databases](#cloudData)
		<li> [S3 Buckets **](#cloudS3)
		<li> [Troubleshooting](#cloudTrouble)
		</ol>
	<li> [CI/CD Pipeline](#cicd)
		<ol>
		<li> [Operations](#cicdOps)
		<li> [Secrets*](#cicdSecrets)
		<li> [Troubleshooting](#cicdTrouble)
		</ol>
	<li> [Content Authoring](#content)
		<ol>
		<li> [Editing Content](#contentEdit)
		<li>[Deploying Content](#contentDeploy)
		<li> [Troubleshooting](#contentTrouble)
		</ol>
</ol> 

## 1. <a name='api'>API Gateway </a>

### <a name='apiConfig'>**Configuration**
### <a name='apiTrouble'>**Troubleshooting**

## 2.  <a name='cors'> CORS Policy Administration

### <a name='corsPolicy'>**Adding/Removing CORS policy**
### <a name='corsTrouble'>**Troubleshooting**

## 3.  <a name='data'>Data Migration
### <a name='dataCapture'>**Change data capture**
### <a name='dataJob'>**Job Timing**
### <a name='dataTrouble'>**Troubleshooting**

## 4.<a name='quartz'> Quartz Job Scheduler
### <a name='quartzBulk'>**Bulk Data Files**
### <a name='quartzCheck'>**Check Engine**
### <a name='quartzTrouble'>**Troubleshooting**

## 5. <a name='cloud'>Cloud.gov
###<a name='cloudManage'> **Managing app resources (memory, instances)**
### <a name='cloudData'>**Databases**
### <a name='cloudS3'>**S3 Buckets**
### <a name='cloudTrouble'>**Troubleshooting**

## 6.<a name='cicd'> CI/CD Pipeline
### <a name='cicdOps'> Operations</a>

### <a name='cicdSecrets'>**Secrets**
### <a name='cicdTrouble'>**Troubleshooting**

## 7. <a name='content'>Content Authoring</a>
<p>
Our Content Authoring solution allows CAMD Admins to edit the content live on the CAMDP and ECMPS Application through the use of the CAMD Github Repository and S3. Admins are able to update static text content, update release notes, and host a variety of file types on the ite (PDF, Video, ETC)
</p>

###  <a name='contentEdit'>Editing Content</a>
<p>
<ol>
<li> Navigate to the EASEY-Content Repository </li>
<li>Click on the Environement in which you are trying to edit content</li>
<li>Click on the Application you are trying to edit </li>
<li> Click on the Page in which you are trying to edit content </li>
<li>Find and click on the Markdown or JSON file associated with the section you are trying to edit content </li>
<li>In the Upper Right hand corner of the box that contains the content for your desired section, click the pen icon </li>
<li> Ensure that your changes are in the correct format by viewing the document preview (The Eye icon in the top left corner of the editing menu) </li>
</ol>
</p>

### <a name='contentDeploy'> Deploying Content</a>
<p>
<ol>
<li> After making your desired changes, scroll to the bottom of the page to the commit changes box</li>
<li>Provide a description of the changes you made </li>
<li> Select the Radio button that reads "Commit directly to the master branch." </li>
<li> Click "Commit Changes"</li>

</ol>
</p>


### <a name='contentTrouble'>Troubleshooting </a>

