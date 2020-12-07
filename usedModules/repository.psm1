﻿Using module .\license.psm1
Using module .\branch.psm1
Using module .\gitHubError.psm1

# Definition of the Repository Powershell class to define a repository from the GitHub API...
class Repository
{

    # All attributes of the Repository class...
    hidden [int]$id
    hidden [string]$nodeID
    hidden [string]$name
    hidden [string]$fullName
    hidden [bool]$isPrivate
    hidden [string]$ownerID
    hidden [string]$ownerLogin
    hidden [string]$page
    hidden [string]$description
    hidden [bool]$isFork
    hidden [System.Array]$forks
    hidden [int]$forksCount
    hidden [System.Array]$contributors
    hidden [System.Array]$subscribers
    hidden [System.Array]$branches = @()
    hidden [License]$license
    hidden [string]$gitURL
    hidden [string]$sshURL
    hidden [string]$cloneURL
    hidden [string]$svnURL
    hidden [string]$archiveURL
    hidden [string]$homePage
    hidden [bool]$isArchived
    hidden [string]$mainLanguage
    hidden [System.Collections.Hashtable]$allLanguages = @{}
    hidden [GitHubError]$error

    # Repository class constructor with user login and repository name...
    Repository([string]$wishedUserLogin, [string]$wishedRepositoryName)
    {
        # Create an HTTP request to take the GitHub repository identified by its name and its owner's login...
        $githubGetReposURL = "https://api.github.com/repos/" + $wishedUserLogin + "/" + $wishedRepositoryName

        # Create an HTTP request to take all the languages and their respective proportions used in the GitHub repository identified by its name and its owner's login...
        $githubGetLanguagesReposURL = "https://api.github.com/repos/" + $wishedUserLogin + "/" + $wishedRepositoryName + "/languages"

        # Bloc we wish execute to get all informations about the wished repository...
        try {
        
            #
            $githubReposRequest = Invoke-WebRequest -Uri $githubGetReposURL -Method Get
            $githubReposRequestsContent = $githubReposRequest.Content
            $githubReposRequestsJSONContent = @"
               
$githubReposRequestsContent
"@
            $githubReposRequestsResult = ConvertFrom-Json -InputObject $githubReposRequestsJSONContent

            <#

            #>
            $githubLanguagesReposRequest = Invoke-WebRequest -Uri $githubGetLanguagesReposURL -Method Get
            $languagesJSONObj = ConvertFrom-Json $githubLanguagesReposRequest.Content
            $languagesHash = @{}
            $totalValue = 0
            foreach($property in $languagesJSONObj.PSObject.Properties) {

                $languagesHash[$property.Name] = $property.Value
                $totalValue = $totalValue + $property.Value
            }

            #
            $this.id = $githubReposRequestsResult.id
            $this.nodeID = $githubReposRequestsResult.node_id
            $this.name = $githubReposRequestsResult.name
            $this.fullName = $githubReposRequestsResult.full_name
            $this.isPrivate = $githubReposRequestsResult.private
            $this.ownerLogin = $githubReposRequestsResult.owner.login
            $this.ownerID = $githubReposRequestsResult.owner.id
            $this.page = $githubReposRequestsResult.html_url
            $this.description = $githubReposRequestsResult.description
            $this.isFork = $githubReposRequestsResult.fork
            $this.forksCount = $githubReposRequestsResult.forks_count

            # Call of the static function 'listAllBranches' of the PowerShell class 'Branch' to obtain all the branches of the repo...
            $this.branches = [Branch]::listAllBranches($this.ownerLogin, $this.name)
            
            #
            $this.forks = @()

            #
            $this.contributors = @()

            #
            $this.subscribers = @()

            #
            If($githubReposRequestsResult.license) {

                $this.license = [License]::new($githubReposRequestsResult.license.key, $githubReposRequestsResult.license.name, $githubReposRequestsResult.license.spdx_id, $githubReposRequestsResult.license.url, $githubReposRequestsResult.license.node_id)

            } Else {

                $this.license = $null
            }

            #
            $this.gitURL = $githubReposRequestsResult.git_url
            $this.sshURL = $githubReposRequestsResult.ssh_url
            $this.cloneURL = $githubReposRequestsResult.clone_url
            $this.svnURL = $githubReposRequestsResult.svn_url
            $this.archiveURL = $githubReposRequestsResult.archive_url
            $this.homePage = $githubReposRequestsResult.homepage
            $this.isArchived = $githubReposRequestsResult.archived
            $this.mainLanguage = $githubReposRequestsResult.language

            #
            foreach($key in $languagesHash.Keys) {

                $percentage = ($languagesHash[$key] * 100)/$totalValue

                $this.allLanguages.Add($key, [Math]::Round($percentage, 1))
            }

        # Bloc to execute if an System.Net.WebException is encountered...
        } catch [System.Net.WebException] {

            $errorType = $_.Exception.GetType().Name

            $errorMessage = $_.Exception.Message

            $errorStackTrace = $_.Exception.StackTrace

            $this.error = [GitHubError]::new($errorType, $errorMessage, $errorStackTrace)
        }
    }

    # Definition of a static function to put all repositories of a user identified by its login inside an array...
    static [System.Array] listAllRepositoriesFromLogin([string]$login)
    {
        # Extract all the data relating to all the repositories of the desired user from the received JSON ...
        $githubGetReposURL = "https://api.github.com/users/" + $login + "/repos"
        $githubReposRequest = Invoke-WebRequest -Uri $githubGetReposURL -Method Get
        $githubReposRequestsContent = $githubReposRequest.Content
        $githubReposRequestsJSONContent = @"
               
$githubReposRequestsContent
"@
        $githubReposRequestsResult = ConvertFrom-Json -InputObject $githubReposRequestsJSONContent

        return @()
    }

    #
    [String] ToString()
    {
        If(!$this.error) {

            $returningString =  "`n" + "-----------------" + "Presentation" + "-----------------" + "`n" +
                   "Id: " + $this.id + "`n" +
                   "Node Id: " + $this.nodeID + "`n" +
                   "Name: " + $this.name + "`n" +
                   "Full name: " + $this.fullName + "`n" +
                   "Page: " + $this.page + "`n" +
                   "Is it private ? " + $this.isPrivate + "`n" +
                   "Is it a fork ? " + $this.isFork + "`n" +
                   "Is it archived ? " + $this.isArchived + "`n" + "`n" +

                    "-----------------" + "Owner" + "-----------------" + "`n" +

                    "Owner ID: " + $this.ownerID + "`n" +
                    "Owner login: " + $this.ownerLogin + "`n" + "`n" +

                    "-----------------" + "Languages" + "-----------------" + "`n" +

                    "Main language: " + $this.mainLanguage + "`n" + "`n"

                    foreach($language in $this.allLanguages.Keys) {

                        $returningString += $language + ": " + $this.allLanguages[$language] + "%" + "`n"
                    }

                    $returningString += "`n"

                    $returningString += "-----------------" + "Branches" + "-----------------" + "`n"

                    foreach($branch in $this.branches) {
                        
                        $returningString += "Name: " + $branch.getName() + "`n"
                        $returningString += "Last commit SHA: " + $branch.getLasCommitSha() + "`n"
                        $returningString += "Last commit URL: " + $branch.getLastCommitURL() + "`n"
                        $returningString += "Is is protected ? " + $branch.getIsProtected() + "`n" + "`n"
                    }

                    $returningString += "`n"

                    $returningString += "-----------------" + "License" + "-----------------" + "`n" +

                    "Name: " + $this.license.getName() + "`n" +
                    "SPDX Id: " + $this.license.getSpdxID() + "`n" +
                    "License URL: " + $this.license.getLicenseURL() + "`n" +
                    "Key: " + $this.license.getKey() + "`n" +
                    "Node Id: " + $this.license.getNodeID() + "`n" + "`n" +

                    "-----------------" + "Contributors" + "-----------------" + "`n" + "`n" +

                    "-----------------" + "Subscribers" + "-----------------" + "`n" + "`n" +

                    "-----------------" + "Links" + "-----------------" + "`n" +

                    "Git URL: " + $this.gitURL + "`n" +
                    "ssh URL: " + $this.sshURL + "`n" +
                    "svn URL: " + $this.svnURL + "`n" +
                    "home page: " + $this.homePage + "`n"

          } Else {

                    $returningString = $this.error.ToString()
          }

          return $returningString
    }

    # 'id' attribute getter...
    [int] getId()
    {
        return $this.id
    }

    # 'nodeID' attribute getter...
    [string] getNodeID()
    {
        return $this.nodeID
    }

    # 'name' attribute getter...
    [string] getName()
    {
        return $this.name
    }

    # 'fullName' attribute getter...
    [string] getFullName()
    {
        return $this.fullName
    }

    # 'isPrivate' attribute getter...
    [bool] getIsPrivate()
    {
        return $this.isPrivate
    }

    # 'ownerID' attribute getter...
    [string] getOwnerID()
    {
        return $this.ownerID
    }

    # 'ownerLogin' attribute getter...
    [string] getOwnerLogin()
    {
        return $this.ownerLogin
    }

    # 'page' attribute getter...
    [string] getPage()
    {
        return $this.page
    }

    # 'description' attribute getter...
    [string] getDescription()
    {
        return $this.description
    }

    # 'isFork' attribute getter...
    [bool] getIsFork()
    {
        return $this.isFork
    }

    # 'forks' attribute getter...
    [System.Array] getForks()
    {
        return $this.forks
    }

    # 'forksCount' attribute getter...
    [int] getForksCount()
    {
        return $this.forksCount
    }

    # 'contributors' attribute getter...
    [System.Array] getContributors()
    {
        return $this.contributors
    }

    # 'subscribers' attribute getter...
    [System.Array] getSubscribers()
    {
        return $this.subscribers
    }

    # 'license' attribute getter...
    [License] getLicense()
    {
        return $this.license
    }

    # 'gitURL' attribute getter...
    [string] getGitURL()
    {
        return $this.gitURL
    }

    # 'sshURL' attribute getter...
    [string] getSshURL()
    {
        return $this.sshURL
    }

    # 'cloneURL' attribute getter...
    [string] getCloneURL()
    {
        return $this.cloneURL
    }

    # 'svnURL' attribute getter...
    [string] getSvnURL()
    {
        return $this.svnURL
    }

    # 'archiveURL' attribute getter...
    [string] getArchiveURL()
    {
        return $this.archiveURL
    }

    # 'homePage' attribute getter...
    [string] getHomePage()
    {
        return $this.homePage
    }

    # 'archived' attribute getter...
    [bool] getIsArchived()
    {
        return $this.isArchived
    }

    # 'mainLanguage' attribute getter...
    [string] getMainLanguage()
    {
        return $this.mainLanguage
    }

    # 'allLanguages' attribute getter...
    [System.Collections.Hashtable] getAllLanguages()
    {
        return $this.allLanguages
    }

    # 'branches' attribute getter...
    [System.Array] getBranches()
    {
        return $this.branches
    } 

    # 'error' attribute getter...
    [GitHubError] getGitHubError()
    {
        return $this.error
    }
}