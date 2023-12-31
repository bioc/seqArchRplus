## Functions for downstream analysis of seqArchR clusters
##
## Each of these functions performs the task for one specified sample
## 1. Tag clusters as bed files for viewing in Genome browser/IGV DONE
## 2. Per cluster annotation percentages DONE
## 3. Arranging clusters by IQW, TPM for comparison of architectures DONE
## 4. Seqlogos, usual and strand-separated.
## 5. How to visualize prevalence of clusters on different chromosomes
## 6. Heatmaps arranged by IQW
## 7. Manual curation of clusters

## Handle multicore bpparam object creation using BiocParallel
##
.handle_multicore <- function(crs = 1, parallelize = FALSE) {

    #### Start cluster only once -- using BiocParallel
    if (parallelize) {
        if (.Platform$OS.type == "windows") {
            if (is.null(crs)) crs <- BiocParallel::multicoreWorkers()
            cl <- BiocParallel::SnowParam(
                workers = crs, tasks = crs,
                exportglobals = TRUE
            )
            # cli::cli_alert_info("Parallelization: Yes")
        } else {
            if (is.null(crs)) crs <- BiocParallel::multicoreWorkers()
            cl <- BiocParallel::MulticoreParam(workers = crs, tasks = crs)
            # cli::cli_alert_info("Parallelization: Yes")
        }
    } else {
        cl <- BiocParallel::SerialParam()
        # cli::cli_alert_info("Parallelization: No")
    }
    return(cl)
}
## =============================================================================



.get_strand_plot_title <- function(this_id, nclust, this_n = NULL,
                                    tot_n, strand_val = "+") {
    if (!is.null(strand_val)) {
        if (is.null(this_n)) {
            stop("'this_n' cannot be NULL when strand_val is not NULL")
        }
    }

    clust_names <- sort(as.character(seq(nclust)))

    if (is.null(strand_val)) {
        title_str <- paste0(
            "(", this_id, "/", nclust,
            ") Arch `", clust_names[this_id], "': ",
            tot_n, " sequences"
        )
    } else {
        if (strand_val == "+") {
            title_str <- paste0(
                "(", this_id, "/", nclust,
                ") Arch `", clust_names[this_id], "': ",
                this_n, " (+ strand) /", tot_n
            )
        } else if (strand_val == "-") {
            title_str <- paste0(
                "(", this_id, "/", nclust,
                ") Arch `", clust_names[this_id], "': ",
                this_n, " (- strand) /", tot_n
            )
        }
    }


    title_str
}
## =============================================================================

.get_strand_specific_indices <- function(df, seq_ids_in_cl, strand_val = "+") {
    return(seq_ids_in_cl[which(df$strand[seq_ids_in_cl] == strand_val)])
}
## =============================================================================

## Handle per sample result directory
.handle_per_sample_result_dir <- function(sname, dir_path) {
    result_dir_path <- file.path(dir_path, paste0(sname, "_results"))
    stopifnot(.check_and_create_dir(result_dir_path))
    result_dir_path
}
## =============================================================================

## check_and_create_dir
.check_and_create_dir <- function(dir_path) {
    creation_ok <- FALSE
    if (!dir.exists(dir_path)) {
        cli::cli_alert_warning(paste0("Creating directory: ", dir_path))
        creation_ok <- dir.create(dir_path)
    } else {
        cli::cli_alert_warning(paste0("Directory exists: ", dir_path))
        creation_ok <- TRUE
    }
    ## TRUE: success in creation; FALSE: otherwise
    return(creation_ok)
}
## =============================================================================





.write_empty_string <- function() {
    cat_str <- paste0("<a href= >Empty", "</a>\n")
    cat_str
}
## =============================================================================



.get_clust_id_column <- function(info_df, clusts, use_prefix, use_suffix) {
    ## Add new column noting the cluster IDs from seqArchR result
    clust_lab <- rep("0", length(unlist(clusts)))
    ##
    clust_labels <- .make_cluster_labels(clusts, use_prefix, use_suffix)

    for (i in seq_along(clusts)) {
        clust_lab[clusts[[i]]] <- clust_labels[i]
    }

    ## Return as a factor because this is directly used as y-axis labels
    ## Reverse the levels order so that the clusters are placed top-to-botom
    clust_lab <- factor(clust_lab, levels = rev(clust_labels))

    clust_lab
}
## =============================================================================

.make_cluster_labels <- function(clust, use_prefix, use_suffix) {
    clust_lens <- lengths(clust)
    clust_labels <- paste(paste0("(", clust_lens, ") "),
        use_prefix, seq_along(clust), use_suffix,
        sep = ""
    )
    clust_labels
}
## =============================================================================


## Use this function to get n colors (in sequence) from the specified palette
## -- Can specify n greater than that existing in a palette, in which case
## the colors are recycled and returned
## -- Can also specify a list of colors of choice < n, which are recycled and
## returned. Useful when random colors from a palette are required
.get_ncolors <- function(n, palname = "Set1", clrs = NULL) {

    ## Recycle color vector from RColorBrewer
    use_colors <- clrs
    if (is.null(clrs)) {
        use_colors <- RColorBrewer::brewer.pal(n = n, name = palname)
    }

    nColor <- length(use_colors)
    if (n <= nColor) {
        n_colors <- use_colors[seq_len(n)]
        return(n_colors)
    }

    rep_times <- base::ceiling((n - nColor) / nColor)
    if (n %% nColor == 0) rep_times <- rep_times + 1
    additional <- ((n - nColor) %% nColor)
    col_idx <- c(rep(seq_len(nColor), rep_times), seq_len(additional))
    n_colors <- use_colors[col_idx]
    n_colors
}
## =============================================================================


## Handles preparing a tagcluster GRanges object from either a CAGEexp object
## if that is provided.
## Also, it can be prepared using a BED file provided.
.handle_tc_cager <- function(tc_gr = NULL, cager_obj = NULL, sname,
                                qLow = 0.1, qUp = 0.9) {
    if (is.null(tc_gr)) {
        if (is.null(cager_obj)) {
            stop(
                "`tc_gr` is NULL, did you forgot to supply the `cager_obj`?",
                "Please also specify `qLow` and `qUp` with the `cager_obj`"
            )
        } else {
            if (!requireNamespace("CAGEr", quietly = TRUE)) {
                stop(
                    "Please install R package 'CAGEr' to automatically ",
                    "extract CAGE tag clusters."
                )
            }
            tc_gr <- .get_cage_tc_cager(
                cager_obj = cager_obj, sname = sname,
                qLow = qLow, qUp = qUp
            )
            seqlevels(tc_gr) <- GenomeInfoDb::seqlevels(
                CAGEr::CTSStagCountSE(cager_obj)
            )
            seqinfo(tc_gr) <- GenomeInfoDb::seqinfo(
                CAGEr::CTSStagCountSE(cager_obj)
            )
        }
    }

    if(!(is(tc_gr, "GRanges") || is(tc_gr, "TagClusters"))){
        if(.check_bedfile(tc_gr)){
            cli::cli_alert_info("Reading from Bed file")
            df <- read.delim(tc_gr, header = TRUE, sep="\t")
            tc_gr <- GenomicRanges::makeGRangesFromDataFrame(df,
                keep.extra.columns = TRUE)
        }
        return(list(tc_gr, "bed"))
    }else{
        return(list(tc_gr, NULL))
    }
    stop("Expecting `tc_gr` to be a GRanges object or a bedfile")

}
## =============================================================================

.check_bedfile <- function(bedfname){
    ## Just check if bedfname is valid and exists
    if(file.exists(bedfname))
        return(TRUE)
    return(FALSE)
}
## =============================================================================

.get_cage_tc_cager <- function(cager_obj, sname, qLow, qUp) {
    any_null <- any(unlist(lapply(list(qLow, qUp), is.null)))
    if (any_null) stop("Please specify both `qLow` and `qUp`.")
    message("Using qLow = ", qLow, " and qUp = ", qUp)
    tc_gr <- CAGEr::tagClustersGR(cager_obj,
        sample = sname,
        returnInterquantileWidth = TRUE,
        qLow = qLow, qUp = qUp
    )
    tc_gr
}
## =============================================================================

