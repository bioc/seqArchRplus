% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seqArchRplus_cluster_go_enrichment.R
\name{per_cluster_go_term_enrichments}
\alias{per_cluster_go_term_enrichments}
\title{Perform per cluster GO term enrichment analysis}
\usage{
per_cluster_go_term_enrichments(
  sname = NULL,
  clusts = NULL,
  tc_gr = NULL,
  cager_obj = NULL,
  qLow = 0.1,
  qUp = 0.9,
  txdb_obj = NULL,
  tss_region = NULL,
  orgdb_obj = NULL,
  use_keytype = "ENTREZID",
  one_file = TRUE,
  bar_or_dot = "dot",
  dir_path = NULL,
  txt_size = 12,
  n_cores = 1
)
}
\arguments{
\item{sname}{Sample name. Default is NULL. This is a required argument
if the CAGEexp object is provided. See `cager_obj` argument}

\item{clusts}{List of sequence IDs in each cluster. This can be NULL only
when a BED file is passed to the argument `tc_gr`}

\item{tc_gr}{Tag clusters as \code{\link[GenomicRanges]{GRanges}} or a
BED file (specify filename with path). If `cager_obj` is not provided (i.e.,
 it is NULL), this argument is required. It will be ignored only if
 `cager_obj` is provided. Default is NULL}

\item{cager_obj}{A CAGEexp object obtained from the CAGEr package, if and
when CAGEr was used to process the raw CAGE data}

\item{qLow, qUp}{The interquantile boundaries to be considered for obtaining
tag clusters from the CAGEexp object. See \code{\link[CAGEr]{tagClusters}}}

\item{txdb_obj}{A TxDb object storing transcript metadata}

\item{tss_region}{For ChIPseeker}

\item{orgdb_obj}{Organism-level annotation package}

\item{use_keytype}{Either of "ENTREZID" or "ENSEMBL". Required for use with
\code{\link[clusterProfiler]{enrichGO}}}

\item{one_file}{Logical. Default is TRUE. If set to FALSE the plots of
GO terms enriched per cluster are returned as a list, else all are
written to a single file as separate pages}

\item{bar_or_dot}{Specify "dot" for dotplot (default), or "bar" for barplot}

\item{dir_path}{Specify the /path/to/directory to store results}

\item{txt_size}{Adjust text size for the plots}

\item{n_cores}{For future use}
}
\value{
The list of dot plots showing GO term enrichments per cluster. This is a
list of ggplot2 plots.

When `one_file` is set to TRUE (default), in addition to returning the list
of dot plots, these plots are also written to disk as a PDF, with one plot
per page.
}
\description{
This function helps identify GO terms enriched per cluster.
This requires that the annotations are available as a TxDb object. The
selected genomic regions can be specified as a single GenomicRanges object.
These regions can be specified directly as a BED file (when available) or
select specific regions from a larger set of regions based on some
clustering.
}
\details{
Both `txdb_obj` and `orgdb_obj` are required.



Per cluster, the enriched GO terms are visualized as a dot plot which shows
the enriched terms on the vertical axis and the ratio of genes that are
enriched for the given GO term vs. the total genes in the cluster.
}
\examples{
library(GenomicRanges)
library(TxDb.Dmelanogaster.UCSC.dm6.ensGene)
library(ChIPseeker) ## important to load this package
library(org.Dm.eg.db)

bed_fname <- system.file("extdata", "example_info_df.bed.gz",
         package = "seqArchRplus", mustWork = TRUE)

info_df <- read.delim(file = bed_fname, sep = "\t", header = TRUE)

tc_gr_from_df <- GenomicRanges::makeGRangesFromDataFrame(info_df,
                                                  keep.extra.columns = TRUE)

tc_gr <- readRDS(system.file("extdata", "example_tc_gr.rds",
         package = "seqArchRplus", mustWork = TRUE))

use_clusts <- readRDS(system.file("extdata", "example_clust_info.rds",
         package = "seqArchRplus", mustWork = TRUE))

tdir <- tempdir()

# Get GO term enrichments for all clusters in use_clusts
go_pl <- per_cluster_go_term_enrichments(sname = "sample1",
                         clusts = use_clusts[1:2],
                         tc_gr = tc_gr_from_df,
                         txdb_obj = TxDb.Dmelanogaster.UCSC.dm6.ensGene,
                         dir_path = tdir,
                         one_file = FALSE,
                         tss_region = c(-500,100),
                         orgdb_obj = "org.Dm.eg.db")



}
\author{
Sarvesh Nikumbh
}
