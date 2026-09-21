# Instructor Guide
## Catshark Museomics Workshop

This guide accompanies the student-facing `README.md`.

---

# Teaching objective

The workshop should feel like an investigation, not like a command-line demonstration.

The narrative is:

```text
museum specimen
→ choose a reference
→ inspect sequence files
→ inspect sequencing reads
→ assess quality
→ map reads
→ inspect mapping evidence
→ reconstruct sequence
→ identify sequence
→ compare with catshark references
→ infer a small COI tree
→ discuss what the result means
```

A useful recurring teaching pattern is:

> **Question → command → inspect output → interpretation**

---

# Recommended duration

This is best treated as a **~3-hour workshop**.

A realistic schedule is:

| Time | Activity |
|---|---|
| 09:00–09:15 | Adrian Brajkovic: biological / taxonomic background |
| 09:15–09:25 | Museomics, historical DNA and workshop question |
| 09:25–09:40 | Instructor demonstration: where genomic data live at NCBI |
| 09:40–10:00 | Students search for and save a mitochondrial/COI reference |
| 10:00–10:15 | Inspect FASTA + raw FASTQ |
| 10:15–10:30 | FastQC |
| 10:30–10:40 | Short break |
| 10:40–11:00 | Mapping + BAM inspection + flagstat |
| 11:00–11:15 | Coverage + variant file inspection |
| 11:15–11:30 | Consensus + COI standardization |
| 11:30–11:45 | Manual NCBI BLASTN |
| 11:45–12:00 | Add query to prepared FASTA + MAFFT |
| 12:00–12:10 | Clip alignment + inspect lengths |
| 12:10–12:25 | IQ-TREE + Newick + iTOL |
| 12:25–12:30 | Final interpretation / workflow recap |

This can be compressed, but a true two-hour version would require either:
- giving students the reference in advance; or
- making FastQC/tree visualization mostly instructor-led.

---

# NCBI demonstration for the workshop leader

Before students search for a mitochondrial reference, briefly show them where **whole assembled genomes** can be explored and downloaded.

Useful NCBI resources:

- NCBI Datasets:  
  https://www.ncbi.nlm.nih.gov/datasets/

- NCBI Genome Data Viewer:  
  https://www.ncbi.nlm.nih.gov/gdv/

Explain the distinction between:

1. an assembled nuclear genome;
2. an organellar / mitochondrial sequence record;
3. an individual marker such as COI.

For mitochondrial references, NCBI Nucleotide is often the most direct place to search:

https://www.ncbi.nlm.nih.gov/nuccore/

This is a good moment to explain accession numbers and sequence annotations.

---

# Reference-search exercise

Give students the focal specimen/taxon but do not give them the final reference immediately.

Ask pairs to find a sensible candidate.

Allow:
- complete mitochondrial genome; or
- COI sequence.

After ~10–15 minutes, compare candidate accessions as a group.

Discuss:
- species identity;
- completeness;
- annotation;
- reference distance;
- sequence length;
- reference bias.

Then have everyone standardize the selected download to:

```text
reference/reference.fasta
```

## Backup

Always keep a verified reference at:

```text
instructor_backup/reference.fasta
```

If the NCBI search/download becomes slow or confusing, copy it into place:

```bash
cp instructor_backup/reference.fasta reference/reference.fasta
```

---

# Important: whole mitogenome vs. COI

Students may map to either.

If the reference is already COI:
- the masked consensus is already the final COI query.

If the reference is a complete mitogenome:
- reconstruct the mitogenome first;
- then extract the COI region before BLAST and phylogenetic analysis.

Before class, determine the COI coordinates of your preferred backup mitogenome and record them here:

```text
Reference accession:
Reference FASTA name:
COI start:
COI end:
COI strand:
```

If students select a different mitogenome during the workshop, check the NCBI feature annotation and provide the appropriate coordinates.

For a short workshop, it is better for the instructor to verify coordinates than to spend 20 minutes debugging coordinate extraction.

---

# Required workshop files

## Reads

Place the teaching FASTQ at:

```text
data/catshark_reads.fastq.gz
```

The current tutorial assumes a **single-end or merged FASTQ**, which matches the simplified mapping approach.

A small realistic dataset is preferable.

Aim for a file that:
- opens quickly;
- maps in seconds;
- still has enough mitochondrial signal for the exercise.

If the input was created by pre-selecting mitochondrial reads, tell students that the `flagstat` mapping percentage is no longer an estimate of the mitochondrial fraction of the original library.

If possible, a modest subset containing both mitochondrial and background reads makes `flagstat` more informative.

---

## Prepared phylogeny dataset

Prepare:

```text
phylogeny/catshark_COI_reference_set.fasta
```

Recommended:
- ~8–15 catshark COI sequences;
- several close relatives;
- relevant named taxa;
- one sensible outgroup;
- unique, short FASTA headers.

Try to use sequences covering approximately the same COI region.

This keeps MAFFT/ClipKIT interpretation simple.

---

# Suggested checkpoint files

To keep the class moving, prepare:

```text
checkpoints/01_reference.fasta
checkpoints/02_catshark_mapped.bam
checkpoints/02_catshark_mapped.bam.bai
checkpoints/03_catshark_depth.tsv
checkpoints/04_catshark_calls.vcf.gz
checkpoints/04_catshark_calls.vcf.gz.tbi
checkpoints/05_catshark_consensus.fasta
checkpoints/06_catshark_COI.fasta
checkpoints/07_catsharks_COI_aligned.fasta
checkpoints/08_catsharks_COI_aligned_clipped.fasta
checkpoints/09_catshark_COI_tree.treefile
```

A student who has a problem can rejoin at the next stage rather than spending the workshop debugging.

---

# Key teaching points by stage

## FASTA
Ask:
- What starts a FASTA header?
- How many sequences are present?
- How long is the reference?
- Does the length suggest COI or a complete mitogenome?

## FASTQ
Ask:
- Why are there four lines per read?
- How many reads are present?
- What is stored on the fourth line?
- Why is the file compressed?

## FastQC
Ask:
- Which modules warn/fail?
- Does a warning automatically make a dataset unusable?
- What do historical samples change about our expectations?

## BAM
Ask:
- Where did the read map?
- What does the BAM contain that a FASTA does not?
- Why do we index a BAM?

## Flagstat
Emphasize the distinction between:
- mapping rate;
- breadth of coverage;
- depth of coverage.

## Depth
Ask:
- How much of the reference is covered?
- Where are gaps?
- Is 1× enough?
- Why are low-depth positions masked?

## VCF
Explain:
- REF;
- ALT;
- position;
- variant evidence.

Do not try to teach the entire VCF specification.

## Consensus
Emphasize:
- reference-guided reconstruction;
- masking;
- uncertainty;
- difference between observation and imputation.

## BLAST
Have students record:
- query cover;
- percent identity;
- accession;
- species.

Explain that database identification is only as good as the underlying database records.

## Phylogeny
Ask:
- does BLAST agree with the tree?
- where does the museum specimen fall?
- what is the support?
- what are the limits of a single mitochondrial marker?

---

# Circular mitochondrial genome note

A complete mitochondrial genome is biologically circular but represented as a linear FASTA sequence.

Reads spanning the artificial start/end boundary can sometimes map poorly, which may create an apparent coverage drop at the ends of the reference.

For this workshop, this can simply be mentioned if students notice it.

---

# Coverage threshold note

The tutorial masks positions below 3× depth.

This is intentionally simple.

Do not present 3× as a universal historical-DNA standard.

Real analysis may also need:
- mapping-quality filters;
- base-quality filters;
- duplicate handling;
- damage assessment;
- contamination checks;
- strand support;
- minimum allele balance;
- independent replication.

---

# BLAST

Student URL:

https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&PAGE_TYPE=BlastSearch

Students should paste the COI FASTA manually.

This is deliberate: they should see what a query sequence looks like and interact with the BLAST result page.

---

# Tree visualization

Use iTOL:

https://itol.embl.de/upload.cgi

Students:
1. inspect the raw Newick first;
2. download the `.treefile` from Codespaces;
3. upload it to iTOL;
4. locate their museum sequence.

The visual tree is the payoff; the Newick step shows that the tree itself is fundamentally a text file.

---

# End-of-workshop reveal

If desired, finish by showing the research Snakefile.

Explain:

> The commands you ran manually are the same logical stages that a workflow system automates.

This turns Snakemake from an abstract concept into a direct representation of steps the students already understand.
