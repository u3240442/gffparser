	#!/bin/bash

	current_directory=$(pwd)
	echo "cd: $current_directory"

	# Iterate through all files in the current directory
	for file in "$current_directory"/*; do
	    if [[ $file == *.zip ]]; then
		echo "Unzipping ZIP file: $file"
		unzip "$file"
		unzip_dir=$(basename -s .zip "$file")  # Extract directory name without .zip extension
		if [ -d "$unzip_dir" ]; then
		    cd "$unzip_dir"  # Change into the newly created directory
		    echo "Changed into directory: $unzip_dir"

		    # Identify the GFF, FASTA, and TE.GFF3 files
		    fasta_file=$(find . -type f -name "*.fasta")
		    gff_file=$(find . -type f -name "combine_file.gff3")
		    te_gff_file=$(find . -type f -name "human_TE.gff3")
		    
		    # Remove the ./ prefix if it exists
		    fasta_file=${fasta_file#./}
		    gff_file=${gff_file#./}
		    te_gff_file=${te_gff_file#./}

		    if [ -n "$fasta_file" ] && [ -n "$gff_file" ] && [ -n "$te_gff_file" ]; then
			echo "FASTA file: ${fasta_file}"
	    		echo "GFF file: ${gff_file}"
	    		echo "TE.GFF3 file: ${te_gff_file}"

	    		# Run the provided command
	    		maskFastaFromBed -fi ${fasta_file} -fo "${fasta_file}_masked.fasta" -bed "$te_gff_file" -soft
	    		echo "maskFastaFromBed -fi ${fasta_file} -fo "${fasta_file}_masked.fasta" -bed "$te_gff_file" -soft"
	    		convert2blastmask -in "${fasta_file}_masked.fasta" -parse_seqids -masking_algorithm TE -masking_options "TE" -outfmt maskinfo_asn1_bin -out "${fasta_file}_masked.asnb"
	    		echo "convert2blastmask -in "${fasta_file}_masked.fasta" -parse_seqids -masking_algorithm TE -masking_options "TE" -outfmt maskinfo_asn1_bin -out "${fasta_file}_masked.asnb""
		        makeblastdb -dbtype nucl -in "${fasta_file}_masked.fasta" -out "${fasta_file}_masked" -parse_seqids -mask_data "${fasta_file}_masked.asnb"
		        blastn -num_threads 8 -task megablast -db "${fasta_file}_masked" -query "${fasta_file}_masked.fasta" -out "${fasta_file}_masked.xml" -outfmt 5 -dust=yes
		        
		       segmental_duplication_detector.py "${fasta_file}_masked.xml" xml sdd_0.9_3000_3000.gff3 :memory: -g 3000 -l 3000 -a
		       
		       segmental_duplication_gene_analyzer.py sdd_0.9_3000_3000.gff3 "${fasta_file}_masked.xml" ${gff_file} gene_analyze.out -t ${te_gff_file} -g ${fasta_file} --circos
		       
		       circos -conf circos.conf
	    	       break  # Exit the loop if all three files are found	
		    fi

		fi
	    fi
	done


