function gs{
	git status
}

function gh{
	cd C:\Users\mdoerksen.REDMOND\source\repos
}

function gd{
	git diff
}

function gbn{
	git branch $args
	git checkout $args
}

function gb{
	git branch
}

function gc{
	git checkout $args
}

function gpo() {
	$confirmArg=$args[0]
	if ( $confirmArg -eq "-y" ) {
		$branchName=$(git branch | grep "* " | cut -d'*' -f2)
		echo "Pushing changes to GitHub under branch: $branchName"
		git push origin $branchName
	}
	elseif ( $confirmArg -ne "-y" ) {
		echo "You must add -y to the gpo command in order to push changes automatically."
	}
}

oh-my-posh --init --shell pwsh --config "C:\Users\mdoerksen.REDMOND\OneDrive/ -/ Microsoft\ohmyposh.json" | Invoke-Expression
Import-Module -Name Terminal-Icons
