while getopts q:b:m:t:o:r: flag
do
    case "${flag}" in
	q) query_sequence=${OPTARG};;
	b) backbone_sequence=${OPTARG};;
	m) model_path=${OPTARG};;
	t) backbone_tree=${OPTARG};;
	o) outdir=${OPTARG};;
	r) replicate_seq=${OPTARG};;
  a) query_dist=${OPTARG};;
    esac
done
depp_distance.py query_seq_file=$query_sequence model_path=$model_path backbone_seq_file=$backbone_sequence outdir=$outdir replicate_seq=$replicate_seq query_dist=$query_dist
if [ -z "${query_dist+x}" ]
then
echo "distance correcting..."
#mkdir $outdir/depp_tmp
run_apples.py -d "${outdir}/depp.csv" -t "${backbone_tree}" -o "${outdir}/depp_tmp/tmp.jplace"
gappa examine graft --jplace-path "${outdir}/depp_tmp/tmp.jplace" --out-dir "${outdir}/depp_tmp" --allow-file-overwriting --fully-resolve > /dev/null 2>&1
#perl -ne 'if(/^>(\S+)/){print "$1\n"}' $query_sequence > "${outdir}/depp_tmp/seq_name.txt"
while read p; do
    nw_topology -Ib "${outdir}/depp_tmp/tmp.newick" | sed -e's/)*;/,XXXXX:0)ROOT:0;/g' -|nw_reroot - $p| nw_clade - ROOT|nw_labels -I -|grep -v XXXXX > "${outdir}/depp_tmp/${p}_leaves.txt" &
done < "${outdir}/depp_tmp/seq_name.txt"
wait
distance_correction.py outdir=$outdir backbone_tree=$backbone_tree
echo "finish correction!"
#run_apples.py -d "./${ourdir}/depp_correction.csv" -t "./${backbone_tree}" -o "./${outdir}/depp_tmp/tmp.jplace"
rm -rf "${outdir}/depp_tmp/"
fi
