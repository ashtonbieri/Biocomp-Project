#Code for Biocomp-Project for Intro to Biocomputing, BIOS-30318
#Authored solely by Ashton Bieri, netid abieri, email abieri@nd.edu

#Usage from command line:  >bash ./main.sh
#Uses ref sequences from ./ref_sequences with filenames starting with hsp* and mcrA*
#To run on another machine, edit lines(inc. blank lines) 16 and 17 so that ~/muscle represents the muscle program on your system,
#    change lines 21 and 22 with the path to hmmbuild on your system, and lines 31 and 44 to the path to hmmsearch

cd ~/Private/Biocomp-Project

# Step 1: Combine fasta sequences into a .refs file 
cat ./ref_sequences/hsp* > hsp70.refs 
cat ./ref_sequences/mcrA* > mcrA.refs

# Step 2: Align sequences with hammer
~/muscle -in hsp70.refs -out hsp70aligned.refs
~/muscle -in mcrA.refs -out mcrAaligned.refs

# Step 3: Build profile hmm ??
#    uses hsp70aligned.refs, mcrAaligned.refs to make hmmhsp70.txt, hmmmcrA.txt hmmprofiles
~/Private/hmmer/bin/hmmbuild hmmhsp70.txt hsp70aligned.refs
~/Private/hmmer/bin/hmmbuild hmmmcrA.txt mcrAaligned.refs

# Step 4: Search proteomes based on mcrA match
#    add each filename & # of possible matches to mcrAsearch.txt
#    # of possible matches are found by counting the number of match output lines (lines not starting with #)

rm mcrAsearch.txt
for pro in proteomes/*.fasta
do
~/Private/hmmer/bin/hmmsearch --tblout tempsearch.txt hmmmcrA.txt $pro
echo -n "$pro " >> mcrAsearch.txt
cat tempsearch.txt | grep -v "#" | wc -l >> mcrAsearch.txt
done

#get a list of proteomes that have =/ 0 matches ; outputted in format of relative filepath
cat mcrAsearch.txt | grep -v " 0" | cut --delimiter=' ' -f 1 > mcrAmatches.txt

#Step 5: Search proteomes based on matching for hsp70

rm hsp70search.txt
for pro in proteomes/*.fasta
do
~/Private/hmmer/bin/hmmsearch --tblout tempsearch1.txt hmmhsp70.txt $pro
echo -n "$pro " >> hsp70search.txt
cat tempsearch1.txt | grep -v "#" | wc -l >> hsp70search.txt
done


#do the same thing for hsp70, set up formatting for table output
echo -e 'Proteome\t\t\tmcrA matches\thsp70 matches' > table.txt
for pro in proteomes/*.fasta
do
echo -e -n $pro'\t' >> table.txt
mcrA=$(grep "$pro" mcrAsearch.txt | cut --delimiter=' ' -f 2)
hsp70=$(grep "$pro" hsp70search.txt | cut --delimiter=' ' -f 2)
echo "$mcrA               $hsp70" >> table.txt
done

#cuts out all of the rows w/ a 0 for hsp70/mcrA, outputs to file and stdout
cat table.txt | grep -v "matches" | grep -v "[[:space:]][0]" | sort -k 3 -r > matches.txt
echo -e '\n\n\n\nAll Proteomes (available in table.txt):'
cat table.txt
echo -e '\n\nPossible matches, sorted with strongest matches first(available in matches.txt):'
cat matches.txt
