'------------https://github.com/GHbasicuser/RB2RS-Database-Updater------------'
'db-update.vbs v°1.03 (07/05/2022) par GHbasicuser (aka PhiliWeb)'
'Ce Script VBS permet de télécharger et d'installer la dernière'
'liste "non officielle" des stations de radios pour RadioSure'
'Cette liste de stations est une conversion de la base "Radio-Browser.info"'
'-----------------------------------------------------------------------------'
'Si le fichier 'Latest_RB2RS.zip' a moins de 12 Heures on ne va pas plus loin'
Set FS = createobject("Scripting.FileSystemObject")
If Not FS.FileExists("RadioSure.exe") Then 
       Dim oError
       Set oError = CreateObject("WScript.Shell")
       oError.Popup "Problem: This VBS script doesn't seem to be running in the RadioSure folder. (message generated by db-update.vbs)"
       Set oError=Nothing
       wscript.Quit
End If
If FS.FileExists("Stations\Latest_RB2RS.zip") Then
Set Fichier = FS.GetFile("Stations\Latest_RB2RS.zip")   
    If DateDiff("h", Fichier.DateLastModified, Now) < 12 Then wscript.Quit 
    If DateDiff("d", Fichier.DateLastModified, Now) > 30 Then 
       Dim oShell
       Set oShell = CreateObject("WScript.Shell")
       oShell.Popup "RadioSure - The last successful update is more than 30 days old. (message generated by db-update.vbs)"
       Set oShell=Nothing
    End If
Set Fichier = Nothing
End If    
'Téléchargement de la dernière base "RB2RS" sur le serveur perso de francois-neosurf'
dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
xHttp.Open "GET", "http://82.66.77.189:8080/latest.zip", False
xHttp.Send
If xHttp.Status = 200 Then dim bStrm: Set bStrm = createobject("Adodb.Stream") Else wscript.Quit 
with bStrm
    .type = 1
    .open
    .write xHttp.responseBody
    .savetofile "Stations\Latest_RB2RS.zip", 2
end with
Set xHttp = Nothing
Set bStrm = Nothing
'On ne va pas plus loin si le fichier ZIP est trop petit pour réellement contenir une base valide'
Set Fichier = FS.GetFile("Stations\Latest_RB2RS.zip")
If Fichier.Size < 1000000 Then wscript.Quit
'Suppression de la base installée (et de tout éventuel autre fichier ".rsd")'
objStartFolder = "Stations\"
Set objFolder = FS.GetFolder(objStartFolder)
Set colFiles = objFolder.Files
For Each objFile in colFiles
   if instr(objFile.Name,"stations-") <> 0 AND instr(objFile.Name,".rsd") <> 0 then
       FS.DeleteFile(objStartFolder + objFile.Name)
   end if
Next
Set objFolder = Nothing
Set colFiles = Nothing
'Décompression du fichier ZIP contenant la nouvelle base ".rsd" dans le sous-dossier "Stations"'
DossierZip = Fichier.ParentFolder & "\" & "Latest_RB2RS.zip"
DossierDezip = Fichier.ParentFolder & "\" 
Set osa = createobject("Shell.Application" )
nbFic = osa.Namespace(DossierZip).Items.Count 
osa.Namespace(DossierDezip).CopyHere osa.Namespace(DossierZip).Items, 20
Set FS = Nothing
Set Fichier = Nothing
Set osa = Nothing
'Modification du fichier RadioSure.xml avec la date et l'heure de la dernière recherche de mise à jour..'
Set xmlDoc = CreateObject("Microsoft.XMLDOM")
xmlDoc.load "RadioSure.xml"
Set nNode = xmlDoc.selectsinglenode ("//General/LastStationsUpdateCheck")
nNode.text = Year(Now) & "/" & Month(Now) & "/" & Day(Now) & "/" & Hour(Now) & "/" & Minute(Now)
strResult = xmldoc.save("RadioSure.xml")
Set xmlDoc = Nothing
Set nNode = Nothing
'Affiche un message pour informer du succes de la mise à jour pendant 5 secondes'
Dim oSucces
Set oSucces = CreateObject("WScript.Shell")
oSucces.Popup "RadioSure - The Radio Stations database has been updated.", 5
Set oSucces=Nothing
