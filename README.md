<p align="center">
  <img src="assets/catshark_workshop_logo.png" alt="Catshark Museomics Workshop logo" width="360">
</p>
### AI generated image ;) 

# Catshark Museomics Workshop
## From historical museum DNA to a COI sequence and phylogenetic placement

In this hands-on workshop we will reconstruct mitochondrial sequence information from historical catshark museum material and follow the evidence from **raw sequencing reads** to a **phylogenetic tree**.

The central question is:

> **What can sequencing reads recovered from historical museum material tell us about the identity and phylogenetic placement of a specimen?**

The emphasis is not on memorizing commands. Instead, at every step we will ask:

> **What kind of file are we looking at? What information does it contain? What can we conclude from it?**

---

# Before the workshop

Please make sure that you:

- have a free **GitHub account**;
- have verified the email address connected to your GitHub account;
- can log in to GitHub;
- have a modern web browser;
- bring your laptop and charger.

You do **not** need to install bioinformatics software locally.

We will use **GitHub Codespaces**, which gives everyone the same Linux environment in the browser, whether your own computer runs Windows or macOS.

---

# Workshop overview

```text
Historical museum specimen
          ↓
Search for a suitable mitochondrial reference
          ↓
Inspect the reference FASTA
          ↓
Inspect raw sequencing reads
          ↓
FastQC: assess read quality
          ↓
Map reads to the reference
          ↓
Inspect BAM + mapping statistics
          ↓
Inspect depth / coverage
          ↓
Call variants
          ↓
Build a masked consensus sequence
          ↓
Extract / standardize to COI
          ↓
NCBI BLASTN
          ↓
Add sequence to prepared catshark COI dataset
          ↓
MAFFT alignment
          ↓
Clip alignment
          ↓
IQ-TREE
          ↓
Inspect Newick + visualize the tree
          ↓
Taxonomic interpretation
```

---

# 0. Start the Codespace

On the workshop GitHub repository page:

1. Click **Code**.
2. Select **Codespaces**.
3. Click **Create codespace on main**.
4. Wait for the environment to start.

Open the terminal and type:

```bash
pwd
```

Then:

```bash
ls
```

You should see folders such as:

```text
data
reference
phylogeny
results
checkpoints
```

Check that the main tools are installed:

```bash
bwa 2>&1 | head
samtools --version | head
bcftools --version | head
fastqc --version
mafft --version
clipkit --version
iqtree2 --version
```

<details>
<summary>💡 Why are we using Codespaces?</summary>

Everyone receives the same Linux environment with the same software versions.

This avoids differences between Windows and macOS and prevents us from spending workshop time installing bioinformatics software.

</details>

---

# 1. Find a suitable mitochondrial reference

Before mapping the reads, we need to decide **what sequence to map them against**.

This is a biological decision.

Open **NCBI Nucleotide**:

https://www.ncbi.nlm.nih.gov/nuccore/

Search using the focal taxon provided by the workshop leader.

Useful search terms might include:

```text
SPECIES_NAME mitochondrion complete genome
SPECIES_NAME COI
SPECIES_NAME CO1
SPECIES_NAME cytochrome c oxidase subunit I
```

You may find:

- a complete mitochondrial genome;
- a partial mitochondrial genome;
- a COI / CO1 sequence;
- no sequence for the exact species, but sequences from close relatives.

For this exercise, either a **complete mitochondrial genome** or a **COI sequence** can be used as the mapping reference.

---

## Question 1.1 — What makes a good reference?

Discuss with the person next to you:

- Is the reference from the same species?
- If not, how closely related is it?
- Is it a complete mitogenome or only COI?
- Is the record well annotated?
- Does the record have an accession number?
- How confident are we in the taxonomic identification?

<details>
<summary>💡 Click to reveal discussion points</summary>

A useful reference should ideally be closely related to the specimen and have reliable annotation and identification.

A more distant reference can still work, especially for conserved mitochondrial regions, but reads that differ strongly from the reference may map less efficiently.

This can introduce **reference bias**: our reconstruction is influenced by the sequence we choose as the starting point.

The same-species reference is therefore often useful, but it is not automatically perfect. Public database records can also contain identification or annotation problems.

</details>

---

## Save the reference

Open the chosen NCBI record.

Download the sequence in **FASTA** format.

Then upload or drag the FASTA file into the `reference/` folder in your Codespace.

Rename it:

```text
reference/reference.fasta
```

Check that it exists:

```bash
ls -lh reference/
```

---

# 2. Inspect the reference FASTA

Before using the file, look inside it.

```bash
head reference/reference.fasta
```

---

## Question 2.1 — What does FASTA format look like?

Can you identify:

- the header;
- the DNA sequence?

<details>
<summary>✅ Show answer</summary>

A FASTA file begins with a header line starting with:

```text
>
```

The following lines contain the nucleotide sequence.

Unlike FASTQ, FASTA does **not** contain per-base sequencing quality scores.

</details>

---

## Question 2.2 — How many sequences are in the reference file?

Try:

```bash
grep "^>" reference/reference.fasta
```

Now count them:

```bash
grep "^>" reference/reference.fasta | wc -l
```

<details>
<summary>✅ What should we expect?</summary>

For this exercise we normally want **one reference sequence**, so the result should usually be:

```text
1
```

If there are several FASTA records in the file, tell the workshop leader before continuing.

</details>

---

## Question 2.3 — How long is the reference sequence?

Remove the header and line breaks, then count the nucleotide characters:

```bash
grep -v "^>" reference/reference.fasta \
    | tr -d '\n\r ' \
    | wc -c
```

Record the result.

<details>
<summary>💡 How can the length help us understand what we downloaded?</summary>

A vertebrate mitochondrial genome is usually on the order of ~16–17 kb.

A standard COI barcode is much shorter, often several hundred base pairs.

The exact length depends on what was deposited in the database, so sequence length is a useful first check that we downloaded what we intended to download.

</details>

---

# 3. Inspect the sequencing reads

Our sequencing file is:

```text
data/catshark_reads.fastq.gz
```

First look at its size:

```bash
ls -lh data/catshark_reads.fastq.gz
```

The `.gz` ending means the FASTQ file is compressed.

---

## Question 3.1 — What does a FASTQ read look like?

Display the first 12 lines:

```bash
zcat data/catshark_reads.fastq.gz | head -n 12
```

Why 12 lines?

<details>
<summary>✅ Show answer</summary>

Each FASTQ read consists of **four lines**:

```text
@read_name
DNA_SEQUENCE
+
QUALITY_SCORES
```

Therefore:

```text
3 reads × 4 lines = 12 lines
```

</details>

---

## Question 3.2 — How many sequencing reads are in the file?

First count the number of lines:

```bash
zcat data/catshark_reads.fastq.gz | wc -l
```

Now calculate the number of reads.

<details>
<summary>✅ Show answer</summary>

FASTQ uses four lines per read, so:

```text
number of reads = number of FASTQ lines / 4
```

For example:

```text
400,000 lines / 4 = 100,000 reads
```

The exact answer depends on the workshop dataset.

</details>

---

## Question 3.3 — How long is the first read?

The second line of a FASTQ record is the DNA sequence.

Try:

```bash
zcat data/catshark_reads.fastq.gz \
    | sed -n '2p' \
    | tr -d '\n' \
    | wc -c
```

<details>
<summary>💡 Why might historical museum DNA contain relatively short fragments?</summary>

DNA breaks into smaller fragments through time and during specimen preservation.

Historical material may therefore contain degraded and fragmented molecules compared with freshly collected tissue.

Read length itself is also influenced by the sequencing platform and library preparation.

</details>

---

# 4. Assess read quality with FastQC

Create a folder for the report:

```bash
mkdir -p results/fastqc
```

Run FastQC:

```bash
fastqc data/catshark_reads.fastq.gz \
    -o results/fastqc
```

List the output:

```bash
ls -lh results/fastqc/
```

You should see an HTML report and a ZIP archive.

---

## Read the FastQC summary in the terminal

```bash
unzip -p results/fastqc/catshark_reads_fastqc.zip \
    '*/summary.txt'
```

---

## Question 4.1 — Which FastQC modules PASS, WARN or FAIL?

Look particularly at:

- Per base sequence quality
- Sequence length distribution
- Adapter content
- Overrepresented sequences

<details>
<summary>💡 How should FastQC warnings be interpreted?</summary>

A FastQC warning is not automatically a reason to discard the dataset.

FastQC describes properties of the sequencing reads. Some warnings can be expected for unusual libraries, targeted data, historical material, or already processed reads.

The important question is **why** a module warns and whether that issue matters for the downstream analysis.

</details>

---

## Optional: open the graphical FastQC report

You can inspect the HTML report visually.

One way is to start a small web server:

```bash
python3 -m http.server 8000 --directory results/fastqc
```

Codespaces should offer to open the forwarded port in your browser.

When finished, return to the terminal and press:

```text
Ctrl + C
```

to stop the server.

---

# 5. Prepare the reference for mapping

BWA needs an index:

```bash
bwa index reference/reference.fasta
```

SAMtools also creates a FASTA index:

```bash
samtools faidx reference/reference.fasta
```

Look at the files that were created:

```bash
ls -lh reference/
```

<details>
<summary>💡 What is an index?</summary>

An index lets a program rapidly locate information in a sequence file instead of repeatedly scanning the entire file from beginning to end.

Different programs create different index formats for their own purposes.

</details>

---

# 6. Map the reads to the reference

Create the output directory:

```bash
mkdir -p results
```

Map the reads and immediately sort the alignments:

```bash
bwa mem -t 2 \
    reference/reference.fasta \
    data/catshark_reads.fastq.gz \
    | samtools sort \
    -o results/catshark_mapped.bam
```

Create a BAM index:

```bash
samtools index results/catshark_mapped.bam
```

Look at the files:

```bash
ls -lh results/catshark_mapped.bam*
```

---

# 7. Inspect the BAM file

BAM is a compressed binary representation of mapped sequencing reads.

We cannot use `cat` directly to read it.

Instead:

```bash
samtools view results/catshark_mapped.bam | head
```

---

## Question 7.1 — Can you find the mapped position?

The beginning of each alignment contains fields including:

```text
read name
FLAG
reference name
position
mapping quality
CIGAR
```

Can you identify the **reference name** and **mapping position** of the first read?

<details>
<summary>💡 What is the BAM file telling us?</summary>

The BAM file links each sequencing read to a position on the selected reference.

It therefore contains the evidence underlying the later consensus sequence.

A consensus FASTA hides most of this detail; the BAM lets us go back to the individual reads.

</details>

---

## Inspect the BAM header

```bash
samtools view -H results/catshark_mapped.bam | head -n 20
```

The header contains information about the reference and the programs involved in creating the BAM.

---

# 8. How many reads mapped? — `flagstat`

Run:

```bash
samtools flagstat results/catshark_mapped.bam
```

Save the output:

```bash
samtools flagstat results/catshark_mapped.bam \
    > results/catshark_flagstat.txt
```

Inspect the saved report:

```bash
cat results/catshark_flagstat.txt
```

---

## Question 8.1 — How many reads mapped?

Record:

- total number of reads;
- number of mapped reads;
- percentage mapped.

---

## Question 8.2 — If 90% of the reads mapped, does that mean 90% of the reference is covered?

<details>
<summary>✅ Show answer</summary>

No.

These are different concepts.

**Mapping percentage** asks:

> What proportion of reads aligned somewhere to the reference?

**Coverage breadth** asks:

> What proportion of reference positions have sequencing data?

**Coverage depth** asks:

> How many reads support each individual reference position?

Many reads could all map to the same small region, producing a high mapping percentage but poor genome-wide coverage.

</details>

---

# 9. Inspect coverage and depth

Calculate read depth at every reference position:

```bash
samtools depth -a results/catshark_mapped.bam \
    > results/catshark_depth.tsv
```

Inspect the first positions:

```bash
head results/catshark_depth.tsv
```

The columns are:

```text
reference    position    depth
```

---

## Question 9.1 — How many reference positions are represented in the depth file?

```bash
wc -l results/catshark_depth.tsv
```

Compare that with the reference length you calculated earlier.

<details>
<summary>✅ What should happen?</summary>

Because we used:

```bash
samtools depth -a
```

positions with zero depth are also reported.

The number of lines should therefore correspond to the length of the reference sequence, assuming the reference contains one sequence.

</details>

---

## Question 9.2 — What is the mean depth?

```bash
awk '{sum += $3; n++} END {print sum/n}' \
    results/catshark_depth.tsv
```

---

## Question 9.3 — How many positions have no coverage?

```bash
awk '$3 == 0' results/catshark_depth.tsv | wc -l
```

---

## Question 9.4 — What proportion is covered at ≥3×?

```bash
awk '{n++; if($3 >= 3) good++}
     END {print 100*good/n "%"}' \
    results/catshark_depth.tsv
```

<details>
<summary>💡 Why do we care about depth?</summary>

A nucleotide supported by many independent reads is generally more convincing than one supported by only one read.

For this teaching exercise we will use **3× depth** as a simple masking threshold.

This is a pedagogical threshold, not a universal rule. Real historical-DNA analyses may also consider mapping quality, base quality, duplicate reads, damage patterns, contamination and other factors.

</details>

---

# 10. Call variants

We now identify positions where our specimen differs from the reference.

```bash
bcftools mpileup \
    -f reference/reference.fasta \
    -a AD,DP \
    -Ou results/catshark_mapped.bam \
    | bcftools call \
    --ploidy 1 \
    -mv \
    -Oz \
    -o results/catshark_calls.vcf.gz
```

Index the VCF:

```bash
tabix -p vcf results/catshark_calls.vcf.gz
```

---

# 11. Inspect the VCF file

Look at the header:

```bash
bcftools view -h results/catshark_calls.vcf.gz | head -n 30
```

Look only at variant records:

```bash
bcftools view -H results/catshark_calls.vcf.gz | head
```

Count the variants:

```bash
bcftools view -H results/catshark_calls.vcf.gz | wc -l
```

---

## Question 11.1 — What do REF and ALT mean?

<details>
<summary>✅ Show answer</summary>

`REF` is the nucleotide in the chosen reference sequence.

`ALT` is the alternative nucleotide supported by the sequencing data.

A called difference is therefore evidence that our specimen may differ from the selected reference at that position.

</details>

---

# 12. Mask poorly covered positions

Create a BED file containing positions with depth below 3:

```bash
awk '$3 < 3 {
    print $1 "\t" ($2-1) "\t" $2
}' results/catshark_depth.tsv \
    > results/low_coverage_lt3.bed
```

Inspect it:

```bash
head results/low_coverage_lt3.bed
```

Count the masked positions:

```bash
wc -l results/low_coverage_lt3.bed
```

---

## Question 12.1 — Why not simply leave the reference nucleotide at positions without enough read evidence?

<details>
<summary>✅ Show answer</summary>

Because that would make it look as though the historical specimen itself supported that nucleotide.

Replacing poorly supported positions with `N` explicitly records uncertainty.

An `N` can therefore be a **more scientifically honest result** than A, C, G or T.

</details>

---

# 13. Build the consensus sequence

Generate a masked consensus:

```bash
bcftools consensus \
    -f reference/reference.fasta \
    -m results/low_coverage_lt3.bed \
    results/catshark_calls.vcf.gz \
    > results/catshark_consensus.fasta
```

Inspect it:

```bash
head results/catshark_consensus.fasta
```

---

## Question 13.1 — How long is the consensus?

```bash
grep -v "^>" results/catshark_consensus.fasta \
    | tr -d '\n\r ' \
    | wc -c
```

---

## Question 13.2 — How many uncertain (`N`) positions are present?

```bash
grep -v "^>" results/catshark_consensus.fasta \
    | tr -d '\n\r ' \
    | grep -o "N" \
    | wc -l
```

<details>
<summary>💡 What exactly is this consensus?</summary>

This is a **reference-guided reconstruction**.

At positions where variants were confidently called, the reference base can be replaced by the allele supported by the reads.

At positions below our depth threshold, we mask the sequence with `N`.

The result is therefore an inference based on both the reference sequence and the sequencing evidence from the museum specimen.

</details>

---

# 14. Standardize the result to COI

For the remainder of the workshop, everyone needs a **COI sequence**, because the prepared comparison dataset contains COI sequences.

There are two possibilities.

---

## If your mapping reference was already COI

Copy the consensus:

```bash
cp results/catshark_consensus.fasta \
   results/catshark_COI.fasta
```

Give it a simple unique name:

```bash
sed -i '1s/.*/>Museum_catshark_COI/' \
    results/catshark_COI.fasta
```

---

## If your mapping reference was a complete mitogenome

The workshop leader will provide the COI coordinates for the selected reference after checking the NCBI annotation.

First index the consensus:

```bash
samtools faidx results/catshark_consensus.fasta
```

Then extract the COI region.

The command will look like:

```bash
samtools faidx \
    results/catshark_consensus.fasta \
    "REFERENCE_NAME:START-END" \
    | sed '1s/.*/>Museum_catshark_COI/' \
    > results/catshark_COI.fasta
```

Replace:

```text
REFERENCE_NAME
START
END
```

with the values supplied by the workshop leader.

---

## Inspect the COI sequence

```bash
cat results/catshark_COI.fasta
```

Check its length:

```bash
grep -v "^>" results/catshark_COI.fasta \
    | tr -d '\n\r ' \
    | wc -c
```

---

# 15. Identify the sequence with NCBI BLASTN

We will run BLAST manually in the browser rather than from the command line.

Open:

https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&PAGE_TYPE=BlastSearch

Display the sequence:

```bash
cat results/catshark_COI.fasta
```

Copy the FASTA sequence and paste it into the **Enter Query Sequence** box.

Run nucleotide BLAST.

---

## Question 15.1 — What are the best matches?

Record for the first few sensible hits:

- species name;
- accession;
- query coverage;
- percentage identity;
- E-value.

<details>
<summary>💡 How should we interpret a BLAST hit?</summary>

A strong BLAST match tells us that our sequence is very similar to sequences already present in the database.

It does **not**, by itself, prove species identity.

Interpretation also depends on:

- how much of the query aligned;
- sequence identity;
- whether the database record is correctly identified;
- whether closely related species share similar or identical COI haplotypes;
- the amount of missing data in our sequence.

BLAST is therefore an important clue, not the entire taxonomic analysis.

</details>

---

# 16. Inspect the prepared catshark COI dataset

The workshop leader has prepared:

```text
phylogeny/catshark_COI_reference_set.fasta
```

Look at the beginning:

```bash
head phylogeny/catshark_COI_reference_set.fasta
```

List all sequence names:

```bash
grep "^>" phylogeny/catshark_COI_reference_set.fasta
```

---

## Question 16.1 — How many sequences are currently in the file?

```bash
grep "^>" phylogeny/catshark_COI_reference_set.fasta \
    | wc -l
```

Record the number.

---

# 17. Add our reconstructed COI sequence

First make a copy so we do not modify the original teaching file:

```bash
cp phylogeny/catshark_COI_reference_set.fasta \
   results/catsharks_with_museum_sample.fasta
```

Append our sequence:

```bash
cat results/catshark_COI.fasta \
    >> results/catsharks_with_museum_sample.fasta
```

---

## Question 17.1 — How many sequences are there now?

```bash
grep "^>" results/catsharks_with_museum_sample.fasta \
    | wc -l
```

<details>
<summary>✅ What should have happened?</summary>

The number of FASTA records should have increased by exactly **one**.

If it increased by more than one, check the file before continuing.

</details>

---

# 18. Align the sequences with MAFFT

Run:

```bash
mafft --auto \
    results/catsharks_with_museum_sample.fasta \
    > results/catsharks_COI_aligned.fasta
```

Check that all sequences are still present:

```bash
grep "^>" results/catsharks_COI_aligned.fasta \
    | wc -l
```

Inspect part of the alignment:

```bash
head -n 30 results/catsharks_COI_aligned.fasta
```

---

## Question 18.1 — Has the number of sequences changed?

<details>
<summary>✅ Show answer</summary>

It should not.

An alignment changes how sequences are arranged relative to one another by introducing gaps where necessary.

It should not create or remove taxa.

</details>

---

## Inspect alignment lengths

A convenient summary is:

```bash
seqkit stats results/catsharks_COI_aligned.fasta
```

For a more manual view of individual aligned lengths:

```bash
awk '
/^>/ {
    if (seq != "") print name, length(seq);
    name=$0;
    seq="";
    next
}
{seq=seq $0}
END {print name, length(seq)}
' results/catsharks_COI_aligned.fasta
```

---

# 19. Clip the alignment

Sequences downloaded from public databases may not all cover exactly the same part of COI.

We will remove poorly aligned / excessively gappy columns using ClipKIT:

```bash
clipkit \
    results/catsharks_COI_aligned.fasta \
    -o results/catsharks_COI_aligned_clipped.fasta
```

Check the sequence count:

```bash
grep "^>" results/catsharks_COI_aligned_clipped.fasta \
    | wc -l
```

Check the alignment summary:

```bash
seqkit stats results/catsharks_COI_aligned_clipped.fasta
```

---

## Question 19.1 — Did clipping change the number of taxa or the number of alignment columns?

<details>
<summary>✅ Show answer</summary>

The **number of taxa should remain the same**.

The **number of alignment columns may decrease**, because trimming removes positions that are considered unsuitable for the final phylogenetic analysis.

This is different from deleting entire sequences.

</details>

---

# 20. Build a phylogenetic tree with IQ-TREE

Run:

```bash
iqtree2 \
    -s results/catsharks_COI_aligned_clipped.fasta \
    -m GTR+G \
    -B 1000 \
    -T AUTO \
    --prefix results/catshark_COI_tree
```

List the resulting files:

```bash
ls -lh results/catshark_COI_tree*
```

The tree itself is:

```text
results/catshark_COI_tree.treefile
```

---

# 21. Inspect the Newick tree

Before opening a graphical tree viewer, look at the raw tree:

```bash
cat results/catshark_COI_tree.treefile
```

It will look something like:

```text
((taxon_A:0.01,taxon_B:0.02)95:0.01,taxon_C:0.04);
```

---

## Question 21.1 — What do the symbols in Newick mean?

<details>
<summary>✅ Show answer</summary>

In simplified terms:

- parentheses `()` group related branches;
- commas `,` separate branches;
- taxon names label the tips;
- values after `:` represent branch lengths;
- internal numbers can represent branch-support values;
- `;` marks the end of the tree.

The text may look complicated, but it is simply a compact way of recording the same branching structure that we visualize graphically.

</details>

---

# 22. Download and visualize the tree

In the Codespaces file browser:

1. Find:

```text
results/catshark_COI_tree.treefile
```

2. Right-click the file.
3. Choose **Download**.

Then open the Interactive Tree Of Life (iTOL) upload page:

https://itol.embl.de/upload.cgi

Upload the `.treefile`.

---

## Question 22.1 — Where does the museum specimen fall?

Discuss:

- Which reference sequence is closest?
- Does it cluster with the species you expected?
- What support does the relevant node have?
- Does the result agree with the BLAST search?
- Are there missing (`N`) positions in our sequence that might affect the analysis?

<details>
<summary>💡 What can we conclude from this tree?</summary>

The tree shows the relationship of our reconstructed COI sequence to the particular reference sequences included in this exercise.

It is useful evidence, but it is **not automatically a complete species phylogeny**.

COI is a single mitochondrial marker and represents the history of mitochondrial DNA, not necessarily the complete evolutionary history of the species.

Taxonomic conclusions should therefore also consider morphology, specimen history, geographic information, other loci/genomic data, and the quality and identification of comparative sequences.

</details>

---

# 23. Final reflection

You have now moved from:

```text
historical museum material
        ↓
raw sequencing reads
        ↓
quality assessment
        ↓
reference selection
        ↓
read mapping
        ↓
mapping statistics
        ↓
coverage
        ↓
variants
        ↓
masked consensus
        ↓
COI
        ↓
BLAST
        ↓
multiple sequence alignment
        ↓
alignment trimming
        ↓
phylogenetic tree
```

The important lesson is that the final sequence and tree are not produced by a single black box.

Every result is built from a chain of evidence and analytical decisions.

---

# File formats encountered today

| File type | What it represents |
|---|---|
| `.fastq.gz` | sequencing reads + per-base quality |
| FastQC `.html` / `.zip` | read-quality report |
| `.fasta` | nucleotide sequences |
| `.bam` | mapped sequencing reads |
| `.bai` | BAM index |
| `.tsv` | tabular depth information |
| `.vcf.gz` | sequence variants relative to the reference |
| `.bed` | genomic intervals / positions |
| aligned `.fasta` | homologous sequences arranged for comparison |
| `.treefile` | phylogenetic tree in Newick format |

---

# If something goes wrong

Start by checking where you are:

```bash
pwd
```

List the current directory:

```bash
ls
```

Check the relevant folder:

```bash
ls -lh data/
ls -lh reference/
ls -lh results/
```

If you fall behind, tell the workshop leader.

Checkpoint files are available so that you can continue with the group without repeating the entire pipeline.
