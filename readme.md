# kronCLI
[![forthebadge](https://forthebadge.com/images/badges/works-on-my-machine.svg)](https://forthebadge.com)

![PowerShell Badge](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=fff&style=flat)
![Windows Badge](https://img.shields.io/badge/Windows-0078D6?logo=windows&logoColor=fff&style=flat)
![Visual Studio Code Badge](https://img.shields.io/badge/Visual%20Studio%20Code-007ACC?logo=visualstudiocode&logoColor=fff&style=flat)

This repo contains a PowerShell script for the creation of a templated markdown-based journal entry for yesterday which imports and compresses images from a given folder. 

I use it as a morning ritual, for the creation of a family chronicle. 

<!-- TOC -->

- [1. setup](#1-setup)
    - [1.1. prereqs](#11-prereqs)
    - [1.2. environmental variables](#12-environmental-variables)
    - [1.3. destinations](#13-destinations)
- [2. instructions](#2-instructions)

<!-- /TOC -->

### 1. setup
#### 1.1. prereqs
* [ImageMagick][#1]
* [MikTex/Pandoc][#2]
* [git/GH][#3]

#### 1.2. environmental variables
* you need the following envirnomental variables

Name                    | Example Value
------------------------|---------------------------------------------------------------
`kronScript`            | `c:\Users\Admin\Documents\workspace\projects\kronCLI\kron.ps1`
`kronMasterImageFolder` | `c:\Users\Admin\Documents\familia\fotky`
`kronFolder`            | `c:\Users\Admin\Documents\familia\kron`

#### 1.3. destinations
* In `kronMasterImageFolder`, create additional folder for the current year
* Each morning, I connect my phone to the PC and download the photos there
    - then I run through them and delete most

### 2. instructions
* Connect the phone to the PC in the PTP transfer mode
* Windows Photo starts automatically (configured as such)
* Select all the photos to be imported
* Navigate to the master folder and delete redundant photos 
    - [Total Commander](https://www.ghisler.com/) for navigation
    - [IrfanView](https://www.irfanview.com/) for quick viewing / deletion
* Run the script `. kron.ps1` and write about your yesterday
    - I set an alias as `k` in the `$profile`
    - You will get an empty day with selected images that are copied to the chronicle's repo folder
    - Save
    - Done
* To merge all posts into `.pdf` to print out:
    1. navigate to the folder of the previous month
    2. run `. kron.ps1 -merge` 

[#1]: https://github.com/pkutaj/kb/blob/master/productivity/2021-03-17-Convert-and-Compress-Images-from-the-Command-Line-with-ImageMagick.md
[#2]: https://github.com/pkutaj/kb/blob/master/productivity/2021-03-20-Markdown-to-Pdf-with-Pandoc-and-Miktex.md
[#3]: https://github.com/pkutaj/kb/blob/master/ntw/2021-03-27-Redirect-to-a-GitHub-Repo-from-a-Top-Level-Domain.md