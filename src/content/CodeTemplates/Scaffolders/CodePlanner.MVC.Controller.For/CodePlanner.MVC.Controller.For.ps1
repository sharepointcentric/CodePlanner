[T4Scaffolding.Scaffolder(Description = "Enter a description of CodePlanner.MVC.Controller.For here")][CmdletBinding()]
param(
	[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$ModelType,        
    [string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $false
)

##############################################################
# NAMESPACE
##############################################################
$namespace = (Get-Project $Project).Properties.Item("DefaultNamespace").Value
$rootNamespace = $namespace
$dotIX = $namespace.LastIndexOf('.')
if($dotIX -gt 0){
	$rootNamespace = $namespace.Substring(0,$namespace.LastIndexOf('.'))
}

##############################################################
# Project Name
##############################################################
$mvcProjectName = $namespace
$coreProjectName = $rootNamespace + ".Core"

##############################################################
# Info about ModelType
##############################################################
$foundModelType = Get-ProjectType $ModelType -Project $coreProjectName
if (!$foundModelType) { return }

##############################################################
# Create the base controller if it not exists
##############################################################
if((Get-ProjectItem "Controllers\BaseController.cs" -Project $mvcProjectName) -eq $null){
	Scaffold CodePlanner.MVC.BaseController 
}

##############################################################
# Create the controller
##############################################################
$outputPath = "Controllers\"+$foundModelType.Name+"Controller"
$ximports = $coreProjectName + ".Model, " + $coreProjectName + ".Interfaces.Service, " + $coreProjectName + ".ViewModel"
$namespace = $mvcProjectName + ".Controllers"

Add-ProjectItemViaTemplate $outputPath -Template MVC.Controller.For `
	-Model @{ 	
	Namespace = $namespace;
	DataTypeName = $foundModelType.Name;
	ExtraUsings = $ximports
	} `
	-SuccessMessage "Added Controller for $ModelType {0}" `
	-TemplateFolders $TemplateFolders -Project $mvcProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $mvcProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {

}