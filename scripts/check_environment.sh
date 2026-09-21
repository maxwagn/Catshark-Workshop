#!/usr/bin/env bash
set -u

echo
echo "============================================"
echo " Catshark workshop environment check"
echo "============================================"
echo

tools=(bwa samtools bcftools tabix fastqc mafft clipkit iqtree2 seqkit)

failed=0
for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf "%-12s OK\n" "$tool"
    else
        printf "%-12s MISSING\n" "$tool"
        failed=1
    fi
done

echo
if [[ -f data/catshark_reads.fastq.gz ]]; then
    echo "Workshop FASTQ: found"
else
    echo "Workshop FASTQ: not yet added (expected data/catshark_reads.fastq.gz)"
fi

if [[ -f phylogeny/catshark_COI_reference_set.fasta ]]; then
    echo "Phylogeny FASTA: found"
else
    echo "Phylogeny FASTA: not yet added (expected phylogeny/catshark_COI_reference_set.fasta)"
fi

echo
if [[ "$failed" -eq 0 ]]; then
    echo "Software check passed."
else
    echo "One or more required programs are missing."
fi
echo
