$ascii=$NULL;
$complexity= 3;
$ascii_array=New-Object "object[]" $complexity
$ascii_array[0]=0..9;
For ($a=48;$a -le 57;$a++) {
$ascii+=,[char][byte]$a;
}

For ($a=97;$a -le 122;$a++) {
$ascii_array[1]+=,[char][byte]$a;
$ascii+=,[char][byte]$a 
}

For ($a=65;$a -le 90;$a++) {
$ascii_array[2]+=,[char][byte]$a;
$ascii+=,[char][byte]$a;
}

Function GET-Temppassword() {

Param(

[int]$length=10,

[string[]]$sourcedata

)
while ($true_ind -lt $complexity) {
    $TempPassword=$NULL;
    $verity=0,0,0;
    $true_ind=0;
    For ($ind=1; $ind –le $length; $ind++) {
        $symb=$sourcedata | GET-RANDOM;
        $TempPassword+=$symb;
        For ($ind1=0; $ind1 -le $complexity-1;$ind1++) {
            if ($verity[$ind1] -eq 0) {
                for ($str_ind=0; $str_ind -le $ascii_array[$ind1].length; $str_ind++) {
                    if ($symb -eq $ascii_array[$ind1][$str_ind]) {
                        $true_ind++;
                        $verity[$ind1]= 1;
                        break;
                    }
                }
            }
        }
    }
}

return $TempPassword

}

$ChkFile = "C:\Program Files (x86)\password_for_MSSQL.txt" 
$FileExists = Test-Path $ChkFile

if ($FileExists -eq $True){
del "C:\Program Files (x86)\password_for_MSSQL.txt"
GET-Temppassword -length 10 -sourcedata $ascii | New-Item -Path 'C:\Program Files (x86)\password_for_MSSQL.txt' -ItemType 'file'
}
else {GET-Temppassword -length 10 -sourcedata $ascii | New-Item -Path 'C:\Program Files (x86)\password_for_MSSQL.txt' -ItemType 'file'}
