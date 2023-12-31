% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seqArchRplus_iqw.R
\name{order_clusters_iqw}
\alias{order_clusters_iqw}
\title{Order clusters by median or mean interquantile widths}
\usage{
order_clusters_iqw(sname, clusts, info_df, order_by_median = TRUE)
}
\arguments{
\item{sname}{The sample name}

\item{clusts}{List of sequence ids in each cluster.}

\item{info_df}{The data.frame with all tag clusters information. The
following columns are expected in the data.frame:"chr", "start", "end",
"width", "strand", "score", "nr_ctss", "dominant_ctss", "domTPM",
"IQW", "tpm" and two additional columns based on qLow and qUp used.}

\item{order_by_median}{Logical. Whether to order to clusters by their
median (when TRUE) or mean (when FALSE) interquantile widths.}
}
\value{
The list of clusters ordered by their mean/median interquantile widths
(shortest first).
}
\description{
Order clusters by median or mean interquantile widths
}
\examples{

bed_fname <- system.file("extdata", "example_info_df.bed.gz",
         package = "seqArchRplus", mustWork = TRUE)

info_df <- read.delim(file = bed_fname,
         sep = "\t", header = TRUE,
         col.names = c("chr", "start", "end", "width",
                 "dominant_ctss", "domTPM",
                 "strand", "score", "nr_ctss",
                 "q_0.1", "q_0.9", "IQW", "tpm"))

use_clusts <- readRDS(system.file("extdata", "example_clust_info.rds",
         package = "seqArchRplus", mustWork = TRUE))


ordered_clusts <- seqArchRplus::order_clusters_iqw(
                                 sname = "sample1",
                                 clusts = use_clusts,
                                 info_df = info_df,
                                 order_by_median = TRUE)

}
\author{
Sarvesh Nikumbh
}
