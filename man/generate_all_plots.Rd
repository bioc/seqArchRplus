% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seqArchRplus_all_wrapper.R
\name{generate_all_plots}
\alias{generate_all_plots}
\title{Generate all plots for a given sample}
\usage{
generate_all_plots(
  sname,
  bed_info_fname,
  custom_colnames = NULL,
  seqArchR_clusts,
  raw_seqs,
  cager_obj = NULL,
  tc_gr = NULL,
  use_q_bound = FALSE,
  use_as_names = NULL,
  order_by_iqw = TRUE,
  use_median_iqw = TRUE,
  iqw = TRUE,
  tpm = TRUE,
  cons = FALSE,
  pos_lab = NULL,
  txdb_obj = NULL,
  orgdb_obj = NULL,
  org_name = NULL,
  qLow = 0.1,
  qUp = 0.9,
  tss_region = c(-500, 100),
  raw_seqs_mh = NULL,
  motifs = c("WW", "SS", "TATAA", "CG"),
  motif_heatmaps_flanks = c(50, 100, 200),
  motif_heatmaps_res = 300,
  motif_heatmaps_dev = "png",
  dir_path,
  txt_size = 25
)
}
\arguments{
\item{sname}{The sample name}

\item{bed_info_fname}{The BED filename with information on tag clusters. See
details for expected columns (column names)/information}

\item{custom_colnames}{Specify custom column/header names to be used
with the BED file information}

\item{seqArchR_clusts}{The seqArchR clusters' list}

\item{raw_seqs}{The sequences corresponding to the cluster elements (also
available from the seqArchR result object)}

\item{cager_obj}{The CAGEr object. This expects that
\code{\link[CAGEr]{clusterCTSS}} has been run beforehand. Default is NULL}

\item{tc_gr}{The tag clusters as a \code{\link[GenomicRanges]{GRanges}}.
Default is NULL}

\item{use_q_bound}{Logical. Write the lower and upper quantiles as tag
cluster boundaries in BED track files with tag clusters. Default is TRUE}

\item{use_as_names}{Specify the column name from info_df which you would like
to use as names for display with the track. By default, `use_names` is NULL,
and the sequence/tag cluster IDs are used as names}

\item{order_by_iqw}{Logical. Set TRUE to order clusters by the IQW median
or mean. Set argument `use_median_iqw` to TRUE to use the median, else will
use mean if FALSE}

\item{use_median_iqw}{Logical. Set TRUE if the median IQW for each cluster
is used to order the clusters. Otherwise, the mean IQW will be used when set
to FALSE}

\item{iqw, tpm, cons}{Logical. Specify TRUE when the corresponding plots
should be included}

\item{pos_lab}{The position labels}

\item{txdb_obj}{The TranscriptsDB object for the organism}

\item{orgdb_obj}{The OrgDb object for the organism}

\item{org_name}{The organism name. This is used in the tracknames for tracks
writte nas BED files}

\item{qLow, qUp}{Numeric values between 0 and 1. These are required when
cager_obj is provided instead of the tag clusters `tc_gr`}

\item{tss_region}{For ChIPseeker, "region range of TSS"}

\item{raw_seqs_mh}{Specify the sequences to be used for motif heatmaps, if
they are different than the sequences clustered by seqArchr. Default is NULL,
when `raw_seqs`` are used}

\item{motifs}{Specify a character vector of motif words (using IUPAC
notation) to be visualized as a heatmap}

\item{motif_heatmaps_flanks}{Specify a vector of different flank values to
be considered for visualization. Same size flanks are considered upstream
as well as downstream, hence one value suffices for eac hvisualization.
When a vector `c(50, 100, 200)` is specified, three motif heatmap files
(three separate PNG files) are created, each with one flank size. The
motif heatmap file will contain separate heatmaps for each of the specified
motifs in the `motifs` argument}

\item{motif_heatmaps_res}{The resolution for the motif heatmaps. Default is
300 ppi}

\item{motif_heatmaps_dev}{The device to be used for plotting. Default is
"png". Other options available are "tiff", "pdf", and "svg"}

\item{dir_path}{The path to the directory where files are saved}

\item{txt_size}{The text size to be used for the plots. This is
some high value because the plots are written with `dpi=300` and are often
large in size, especially the combined panel plots}
}
\value{
A list holding generated plots; some which are directly written to
disk are not included in this list.

The included plots are:

- Boxplots of IQW (and TPM and conservation score when available)
distributions for each cluster (as a single combined plot)
- Annotation percentages per cluster as stacked barplots (as a single
combined plot)
- Annotation percentages per cluster as stacked barplots as a list
- Sequence logos of all cluster architectures (as a single combined plot)
- Sequence logos of all cluster architectures as a list
- Strand-separated sequence logos of all cluster architectures as a list
- Per cluster distribution of tag clusters on chromosomes and strands

In addition, the following plots are written to disk:
- Visualization of all clustered sequences as a matrix
- Visualization of motif occurrences (for specified motifs) in all
clustered sequences

In addition, the individual clusters from seqArchR are written to disk as
BED track files that can be viewed in the genome browser/IGV.
}
\description{
Generate all plots for a given sample
}
\details{
The expected columns (and column names) in the BED file are
"chr", "start", "end", "width", "strand", "score", "nr_ctss",
"dominant_ctss", "domTPM", "q_<qLow>", "q_<qUp>", "IQW", "tpm". Depending on
the values for arguments qLow and qUp, the corresponding column names are
formed. For example, if `qLow` and `qUp` are 0.1 and 0.9, the column names
are "q_0.1" and "q_0.9". These columns are mostly present by default in the
CAGEr tag clusters.

The supplied clusters are ordered by their mean/median interquantile widths
before proceeding to generate the visualizations.
}
\examples{

library(GenomicRanges)
library(TxDb.Dmelanogaster.UCSC.dm6.ensGene)
library(ChIPseeker)
library(Biostrings)

bed_fname <- system.file("extdata", "example_info_df.bed.gz",
         package = "seqArchRplus", mustWork = TRUE)

## info_df <- read.delim(file = bed_fname,
##         sep = "\t", header = TRUE)


tc_gr <- readRDS(system.file("extdata", "example_tc_gr.rds",
         package = "seqArchRplus", mustWork = TRUE))

use_clusts <- readRDS(system.file("extdata", "example_clust_info.rds",
         package = "seqArchRplus", mustWork = TRUE))

raw_seqs <- Biostrings::readDNAStringSet(
                          filepath = system.file("extdata",
                            "example_promoters45.fa.gz",
                            package = "seqArchRplus",
                            mustWork = TRUE)
                        )

raw_seqs_mh <- Biostrings::readDNAStringSet(
                          filepath = system.file("extdata",
                            "example_promoters200.fa.gz",
                            package = "seqArchRplus",
                            mustWork = TRUE)
                        )


all_plots <- generate_all_plots(sname = "sample1",
                   bed_info_fname = bed_fname,
                   seqArchR_clusts = use_clusts,
                   raw_seqs = raw_seqs,
                   tc_gr = tc_gr,
                   use_q_bound = FALSE,
                   order_by_iqw = FALSE,
                   use_median_iqw = TRUE,
                   iqw = TRUE, tpm = TRUE, cons = FALSE,
                   pos_lab = -45:45,
                   txdb_obj = TxDb.Dmelanogaster.UCSC.dm6.ensGene,
                   org_name = "Dmelanogaster22",
                   qLow = 0.1, qUp = 0.9,
                   tss_region = c(-500, 100),
                   raw_seqs_mh = raw_seqs_mh,
                   motifs = c("WW", "SS", "TATAA", "CG"),
                   motif_heatmaps_flanks = c(50, 100, 200),
                   motif_heatmaps_res = 150,
                   motif_heatmaps_dev = "png",
                   dir_path = tempdir(),
                   txt_size = 25)

}
\author{
Sarvesh Nikumbh
}
