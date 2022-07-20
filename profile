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
}

function gc{
	git checkout $args
}

oh-my-posh --init --shell pwsh --config "C:\Users\mdoerksen.REDMOND\OneDrive/ -/ Microsoft\ohmyposh.json" | Invoke-Expression
Import-Module -Name Terminal-Icons
