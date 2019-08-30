shell.executable("/bin/bash")
shell.prefix("source $HOME/.bashrc; ")

import os

configfile: "config.json"

IDS, = glob_wildcards("mags/{id}.fa")

localrules: protein_ox, add_tax_protein_ox, coding_density, popular, parse_coding_density


rule all:
	 input: expand("popular/{sample}.tsv", sample=IDS), expand("coding_density_report/{sample}.tsv", sample=IDS)

rule prodigal:
	input: 'mags/{id}.fa'
	output: 
		faa='proteins/{id}.faa',
		gff='proteins/{id}_prodigal.gff'
	conda: "envs/prodigal.yaml"
	shell: 'prodigal -p meta -a {output.faa} -q -i {input} -f gff -o {output.gff}'


rule coding_density:
	input:
		fa='mags/{id}.fa',
		gff='proteins/{id}_prodigal.gff'
	output: 'coding_density/{id}.tsv'
	shell:
		'''
		perl scripts/coding_density.pl {input.fa} {input.gff} > {output}
		'''

rule parse_coding_density:
	input: 'coding_density/{id}.tsv'
	output: 'coding_density_report/{id}.tsv'
	shell:
		'''
		perl scripts/parse_coding_density.pl {input} > {output}
		'''

rule diamond:
        input: 'proteins/{id}.faa'
        output: 'diamond/{id}.diamond.tsv'
        threads: 16
        params:
                db=config["uniprot_sprot"],
                of="6 qseqid sseqid stitle pident qlen slen length mismatch gapopen qstart qend sstart send evalue bitscore"
        conda: "envs/diamond.yaml"
	shell: "diamond blastp --threads {threads} --max-target-seqs 10 --db {params.db} --query {input} --outfmt {params.of} --out {output}"


rule protein_ox:
	input: 'diamond/{id}.diamond.tsv'
	output: 'protein_ox/{id}.tsv'
	shell:
		'''
		perl scripts/protein_ox.pl {input} > {output}
		'''


rule popular:
	input: 'protein_ox_tax/{id}.tsv'
	output: 'popular/{id}.tsv'
	shell:
		'''
		perl scripts/popular.pl {input} > {output}
		'''

rule add_tax_protein_ox:
	input: 'protein_ox/{id}.tsv'
	output: 'protein_ox_tax/{id}.tsv'
	shell:
		'''
		python scripts/add_tax_protein_ox.py {input} > {output}
		'''


rule diamond_report:
	input: 
		tsv='diamond/{id}.diamond.tsv',
		faa='proteins/{id}.faa'
	output: 'diamond_report/bin.{id}.tsv', 'diamond_report/con.{id}.tsv'
	params:
		outdir="diamond_report"
	conda: "envs/bioperl.yaml"
	shell: "scripts/diamond_report.pl {input.tsv} {input.faa} {params.outdir}"

