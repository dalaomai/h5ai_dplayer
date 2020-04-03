#!/bin/bash

BASEDIR="/mnt/g_upenn"


function hlsfile(){
	file="$1"
	if [[ "${file##*.}" == "mp4" || "${file##*.}" == "mkv" ]]; then
		filename="${file##*/}"
		m3u8dir="${file%/*}/__${filename}__"
		m3u8file="${m3u8dir}/video.m3u8"
		# video_duration=$(ffmpeg -i "${file}" 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/,//)
		m3u8_duration=$(ffmpeg -i "${m3u8file}" 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/,//)
		echo "${filename}  当前切片长度：${m3u8_duration}"
		if [[ ! -f "${file}.aria2"  ]]; then
			if [ ! -d "${m3u8dir}" ]; then
				mkdir -p "${m3u8dir}"
			fi

			
			if  ! cat ${m3u8file} | grep "#EXT-X-ENDLIST" &>/dev/null ; then
				tmp_m3u8dir="/tmp${m3u8dir}"
				tmp_m3u8file="/tmp${m3u8file}"
				echo "临时文件：${tmp_m3u8dir}"
				mkdir -p ${tmp_m3u8dir}

				ffmpeg -i "${file}" -c copy -bsf:v h264_mp4toannexb -hls_time 6 -hls_list_size 0 -hls_segment_filename "${tmp_m3u8dir}/%04d.ts" "${tmp_m3u8file}" > /dev/null 2>&1
				
				mv -f ${tmp_m3u8dir}/* ${m3u8dir}
				echo "${file}  完成切片"
				rm -rf ${tmp_m3u8dir}
			fi
			
		fi
	fi
}

function scandir(){
	for dirfile in "$1"/*
	do
		if [[ -d "${dirfile}" && "${dirfile:0-5}" != "_h5ai" && "${dirfile:0-2}" != "__" ]]; then
			scandir "${dirfile}"
		else
			hlsfile "${dirfile}"
		fi
	done
}
scandir "${BASEDIR}"

echo "休眠后继续"
sleep 12h