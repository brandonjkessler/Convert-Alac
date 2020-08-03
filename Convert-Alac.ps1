param(
        [Parameter(Mandatory)][string]$Path
)

$ffmpeg = "$PSScriptRoot\ffmpeg\bin\"
$ffprobeArgs = "-v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1"


$CurrentLoc = Get-Location

    

Get-ChildItem -Recurse -Path $Path | ForEach-Object{
    #Check to see if the Files in a Path are a Directory
    if(!(Test-Path -Path $_.FullName -PathType Leaf)){ # if 1
        Write-Output "$_ is a directory. Ignoring."
    } else {
        #Verify that the file type is .m4a
        if($_ -like "*.m4a"){ # if 2
            #Verify that the file is an alac file using ffprobe
            if((cmd /c "$ffmpeg\ffprobe.exe $ffprobeArgs `"$($_.FullName)`"") -eq "alac"){ # if 3
                Write-Output "$_ is an ALAC file. Beginning conversion."
                # Trim the .m4a out
                $output = ($_.FullName).Substring(0,(($_.FullName).Length - 4))
                # Convert
                cmd /c "$ffmpeg\ffmpeg.exe -i `"$($_.FullName)`" -c:v copy -c:a flac `"$($output).flac`""
                Write-Output "Successfully converted file $_"
                Write-Warning "Now deleting $($_.FullName)"
                Remove-Item -Path $_.FullName -Force
            } # End if 3
        } # End if 2
    } # End if 1
} # End ForEach-Object


