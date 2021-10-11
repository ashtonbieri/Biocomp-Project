cd ~/Private/Biocomp-Project

# Step 1: Combine fasta sequences into a .refs file 
cat ./ref_sequences/hsp* > hsp70.refs
cat ./ref_sequences/mcrA* > mcrA.refs

# Step 2: Align sequences with hammer
~/muscle -in hsp70.refs -out hsp70aligned.refs
~/muscle -in mcrA.refs -out mcrA.refs

# Step 3: Build profile hmm ??
~/Private/hmmer/bin/hmmbuild hmmhsp70.txt hsp70aligned.refs
~/Private/hmmer/bin/hmmbuild hmmmcrA.txt mcrA.refs

# Step 4: Search proteomes based on mcrA match
# for proteome in [all proteomes]; 
#   search for mcrA presence

#search for mcrA matches in each proteome ; add each filename & # of possible matches
#to mcrAsearch.txt ; 

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

echo -e 'Proteome\t\t\tmcrA matches\thsp70 matches' > table.txt
for pro in proteomes/*.fasta
do
echo -e -n $pro'\t' >> table.txt
mcrA=$(grep "$pro" mcrAsearch.txt | cut --delimiter=' ' -f 2)
hsp70=$(grep "$pro" hsp70search.txt | cut --delimiter=' ' -f 2)
echo "$mcrA               $hsp70" >> table.txt
done

cat table.txt | grep -v "matches" | grep -v "[[:space:]]0" | sort -k 3 -r > matches.txt
echo -e '\n\n\n\nAll Proteomes (available in table.txt):'
cat table.txt
echo -e '\n\nPossible matches, sorted with strongest matches first(available in matches.txt):'
cat matches.txt
