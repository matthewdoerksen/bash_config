function gcr{
      git checkout --track $args[0]
}

function gc{
      git checkout $args[0]
}

function gs{
	git status
}

function gh{
	cd C:\Users\mdoerksen.REDMOND\source\repos
      cd $args[0]
}

function gd{
	git diff
}

function gbn{
	git branch $args[0]
	git checkout $args[0]
}

function gb{
	git branch
}

function dps{
      if ( $args[0] -eq "" ) {
        docker ps
      } else {
        docker ps $args[0]
      }
}

function di{
      docker images
}

function dl{
      docker logs $args[0]
}

function dc{
      docker container $args
}

function da{
      docker attach $args[0]
}

function gpo() {
	$confirmArg=$args[0]
	if ( $confirmArg -eq "-y" ) {
            $branchName1=$(git branch | select-string -Pattern "\* ")
		$branchName=$branchName1.Line.Split('* ')[1]
		echo "Pushing changes to GitHub under branch: $branchName"
		git push origin $branchName
	}
	elseif ( $confirmArg -ne "-y" ) {
		echo "You must add -y to the gpo command in order to push changes automatically."
	}
}

function dependencyscan() {
    $path=Get-Location
    $projectRootFolderName
    $dropFolder="\Drop\Debug\x64\"
    \\hillock\XboxShare\ShowDependencies.cmd
}

function dnc() {
    dotnet nuget locals all --clear
    dotnet restore
    dotnet build
}

oh-my-posh --init --shell pwsh --config "C:\Users\mdoerksen.REDMOND\OneDrive/ -/ Microsoft\ohmyposh.json" | Invoke-Expression
Import-Module -Name Terminal-Icons
