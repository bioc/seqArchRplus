% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/seqArchRplus_cluster_track_bed.R
\name{write_seqArchR_cluster_track_bed}
\alias{write_seqArchR_cluster_track_bed}
\title{Write seqArchR cluster information in BED files viewable as browser
tracks}
\usage{
write_seqArchR_cluster_track_bed(
  sname,
  clusts = NULL,
  info_df,
  use_q_bound = TRUE,
  use_as_names = NULL,
  one_zip_all = FALSE,
  org_name = NULL,
  dir_path,
  include_in_report = FALSE,
  strand_sep = FALSE
)
}
\arguments{
\item{sname}{Sample name}

\item{clusts}{List of sequence ids in each cluster}

\item{info_df}{The data.frame holding information to be written to the BED
file. Expected columns are "chr", "start", "end", "names", "strand",
"domTPM", and "dominant_ctss". Out of these, only "dominant_ctss" column is
optional; when present this is visualised as thickStart and thickEnd.
The "domTPM" column is treated as scores for visualizing by default. One
can also visualize PhastCons score}

\item{use_q_bound}{Logical. Write the lower and upper quantiles as tag
cluster boundaries. Default is TRUE}

\item{use_as_names}{Specify the column name from info_df which you would like
to use as names for display with the track. This is NULL by default,
and the sequence/tag cluster IDs are used as names.}

\item{one_zip_all}{Logical. Specify TRUE when the facility to download BED
files for all clusters with one click is desired, otherwise FALSE. This is
relevant only when include_in_report is TRUE. Default is FALSE}

\item{org_name}{Organism name}

\item{dir_path}{The /path/to/the/directory where a special folder named
`Cluster_BED_tracks` (by default) is created and all BED files are written
inside it. This is a required argument, and cannot be NULL}

\item{include_in_report}{Logical. Specify TRUE when this function is invoked
to write BED files to disk *and* provide downloadable links in the HTML
report. The corresponding chunk in the Rmarkdown report should set the
parameter `result='asis'`. By setting this to FALSE, BED files are written
to disk, but no downloadable links are provided. Note: This should be TRUE,
when `one_zip_all` argument is set to TRUE (see below). Requires the package
`xfun`}

\item{strand_sep}{Logical. Specify TRUE if records for each strand are to
be written in separate BED files}
}
\value{
When \code{`include_in_report = FALSE`}, the cluster information is written
to disk as BED track files that can be viewed in the genome browser or IGV.
Otherwise, a str object holding HTML text is returned that can be included
in the report as downloadable links for each cluster BED file (use
\code{`cat`} function).
When \code{`one_zip_all = TRUE`}, a link to download all files zipped into
one is also provided to enable convenience.
}
\description{
Writes the seqArchR clusters as BED tracks for viewing in IGV
or any genome browser
}
\details{
Note on links in HTML:
For providing downloadable links in the HTML report, the
complete BED files are encoded into base64 strings and embedded with the
HTML report itself. This considerably increases the size of the HTML file,
and can slow down loading of the HTML file in your browser.

Note on BED files:
The output BED files have selected columns provided in the `info_df`.
These are "chr", "start", "end", "name", "score" (see more info below),
 "strand", "dominant_ctss".
By default, the sequence/tag cluster IDs are used as names.
If \code{`use_as_names`} is specified, information from that column in the
`info_df` is used as "name".

If conservation score (e.g., PhastCons) is available, it is used as the
score, otherwise the TPM value of the dominant CTSS (domTPM) is used.
The final two columns (when dominantCTSS column is present), are the
 'thickStart' and `thickEnd' values corresponding to the BED format.
 The 'thickEnd' column is the dominant_ctss position.

Importantly, the lower and upper quantile boundaries are used as the start
and end coordinates of the cluster when `use_q_bound` is set to TRUE
(the default).
}
\examples{

bed_fname <- system.file("extdata", "example_info_df.bed.gz",
         package = "seqArchRplus", mustWork = TRUE)

info_df <- read.delim(file = bed_fname,
         sep = "\t", header = TRUE)

use_clusts <- readRDS(system.file("extdata", "example_clust_info.rds",
         package = "seqArchRplus", mustWork = TRUE))


# Write seqArchR clusters of promoters/CAGE tag clusters as BED track files
# All possible variations are enlisted here

# Using quantiles information as the tag cluster boundaries
# via arg `use_q_bound = TRUE` and using custom names for each.
# Create a new/custom column, and specify the new column name for argument
# `use_as_names`. Notice that any custom names can be obtained by this
# approach.

info_df$use_names <- paste(rownames(info_df), info_df$domTPM, sep = "_")

write_seqArchR_cluster_track_bed(sname = "sample1",
                                 clusts = use_clusts,
                                 info_df = info_df,
                                 use_q_bound = FALSE,
                                 use_as_names = "use_names",
                                 dir_path = tempdir()
                                 )

# Generating textual output that can be included in HTML reports.
# This requires package xfun.
\donttest{
cat_str <- write_seqArchR_cluster_track_bed(sname = "sample1",
                                 clusts = use_clusts,
                                 info_df = info_df,
                                 use_q_bound = FALSE,
                                 use_as_names = "use_names",
                                 dir_path = tempdir(),
                                 include_in_report = TRUE,
                                 one_zip_all = TRUE
                                 )
}


}
\author{
Sarvesh Nikumbh
}
