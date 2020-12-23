﻿# Importation of the 'License' module...
Using module ..\usefulClassesAndObjects\License.psm1

# Definition of all parameters : '$wishedLicenseKey' for the wished license's key...
param (
    [string]$wishedLicenseKey
)

# Creation of an instance of the License Powershell class with all wished parameters...
$currentLicense = New-Object -TypeName License -ArgumentList $wishedLicenseKey

# Display all collected informations about the wished license in the Powershell console...
$currentLicense.ToString()