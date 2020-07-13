ffmpeg -i video.mp4 -i music.mp3 -c:v copy \
       -filter_complex "[0:a]aformat=fltp:44100:stereo,apad[0a];[1]aformat=fltp:44100:stereo,volume=1.5[1a];[0a][1a]amerge[a]" \
       -map 0:v -map "[a]" -ac 2 output.mp4