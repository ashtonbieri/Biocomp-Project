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

# Step 4: Search proteomes based on matches
# for proteome in [all proteomes]; 
#   search for mcrA presence
#   search for several hsp70 genes

#search for mcrA matches in each proteome ; add each filename & # of possible matches
#to mcrAsearch.txt ; 
rm mcrAsearch.txt
for pro in proteomes/*.fasta
do
~/Private/hmmer/bin/hmmsearch --tblout tempsearch.txt hmmmcrA.txt $pro
echo -n $pro ' ' >> mcrAsearch.txt
cat tempsearch.txt | grep -v "#" | wc -l >> mcrAsearch.txt
done

#get a list of proteomes that have =/ 0 matches ; outputted in format of relative filepath
cat mcrAsearch.txt | grep -v " 0" | cut --delimiter=' ' -f 1 > mcrAsearch.txt

