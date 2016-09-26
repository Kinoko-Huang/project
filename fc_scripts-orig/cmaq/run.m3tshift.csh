#! /bin/csh

 set JWANT = $argv[1]
 setenv INFILE $argv[2]
 setenv OUTFILE $argv[3]

 echo "" > m3t.inp
 echo "" >> m3t.inp
 echo "" >> m3t.inp
 echo $JWANT >> m3t.inp
 echo "" >> m3t.inp
 echo "" >> m3t.inp
 echo "" >> m3t.inp
 echo "" >> m3t.inp

 $PWD/m3tshift < m3t.inp

