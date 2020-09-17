package com.video.luojigou_image_picker;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.net.Uri;
import android.util.Log;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.microshow.rxffmpeg.RxFFmpegInvoke;
import io.microshow.rxffmpeg.RxFFmpegSubscriber;

public class VideoPlugin {
    private static final String TAG = VideoPlugin.class.getSimpleName();

    public static void xxx(MainActivity activity, MethodCall call, MethodChannel.Result result) {
        Log.d("VideoPlugin", "xxx: " + call.arguments);
        new Thread(() -> {
            try {
                String inputVideoUrl = call.arguments.toString();
                Log.d(TAG, "xxx:  new File(inputVideoUrl).length()===>>" + new File(inputVideoUrl).length());
                String outVideoUrl = Objects.requireNonNull(activity.getActivity().getExternalCacheDir()).getPath() + "/update-video-temp-001.mp4";
                String scaleParam = "";
                Bitmap thumbnailBitmap = getLocalVideoThumbnail002(inputVideoUrl);
                if (thumbnailBitmap == null) {
                    return;
                }
                int height = thumbnailBitmap.getHeight();
                int width = thumbnailBitmap.getWidth();
                Log.d(TAG, "xxx: height==>>" + height);
                Log.d(TAG, "xxx: width==>>" + width);
                if (width > height) {
                    if (width > 480)
                        scaleParam = " -vf scale=480:-1";
                } else {
                    if (height > 480)
                        scaleParam = " -vf scale=-1:480";
                }
                String cmd = "";
                if (scaleParam.length() == 0) {
                    cmd = "ffmpeg -y -i " + inputVideoUrl + " " + outVideoUrl;
                } else {
                    cmd = "ffmpeg -y -i " + inputVideoUrl + " -b 1000k" + scaleParam + " -preset superfast " + outVideoUrl;
                }
//
                Log.d(TAG, "xxx: " + cmd);
                String[] commands = cmd.split(" ");
                MyRxFFmpegSubscriber myRxFFmpegSubscriber = new MyRxFFmpegSubscriber(activity, outVideoUrl, result);
                RxFFmpegInvoke.getInstance()
                        .runCommandRxJava(commands)
                        .subscribe(myRxFFmpegSubscriber);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }

    /**
     * @param path
     * @return
     */
    private static int[] getVideoInfo(String path) {
        String info = null;
        try {
            info = RxFFmpegInvoke.getInstance().getMediaInfo(path);
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.d(TAG, "getVideoInfo: " + info);
        String pattern = "videostream_codecpar_width=([0-9]*);videostream_codecpar_height=([0-9]*);videostream_sample_aspect_ratio_num=([0-9]);";
        Pattern r = Pattern.compile(pattern);
        Matcher m = r.matcher(info);
        if (m.find()) {
            int width = Integer.parseInt(m.group(1));
            int height = Integer.parseInt(m.group(2));
            int rotation = Integer.parseInt(m.group(3));
            if (rotation == 1) {
                if (width > height) {
                    return new int[]{width, height};
                } else {
                    return new int[]{height, width};
                }
            } else {
                if (width > height) {
                    return new int[]{height, width};
                } else {
                    return new int[]{width, height};
                }
            }
        }
        return null;
    }

    private static String getLocalVideoThumbnail(Context context, String videoUrl) {
        MediaMetadataRetriever media = new MediaMetadataRetriever();
        media.setDataSource(videoUrl);
        Bitmap bitmap = media.getFrameAtTime();
        return saveBitmap(context, bitmap);
    }


    private static Bitmap getLocalVideoThumbnail002(String videoUrl) {
        MediaMetadataRetriever media = new MediaMetadataRetriever();
        File file = new File(videoUrl);
        media.setDataSource(file.getAbsolutePath());
        Bitmap bitmap = media.getFrameAtTime();
        media.release();
        return bitmap;
    }


    /**
     * @param context
     * @param mBitmap
     * @return
     */
    private static String saveBitmap(Context context, Bitmap mBitmap) {
        File filePic;
        try {
            filePic = new File(context.getExternalCacheDir() + "/video-temp-thumbnail.jpg");
            if (!filePic.exists()) {
                filePic.createNewFile();
            }
            FileOutputStream fos = new FileOutputStream(filePic);
            mBitmap.compress(Bitmap.CompressFormat.JPEG, 80, fos);
            fos.flush();
            fos.close();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
        return filePic.getAbsolutePath();
    }

    public static class MyRxFFmpegSubscriber extends RxFFmpegSubscriber {

        private MainActivity activity;
        private String videoUrl;
        private MethodChannel.Result result;

        public MyRxFFmpegSubscriber(MainActivity activity, String videoUrl, MethodChannel.Result result) {
            this.activity = activity;
            this.videoUrl = videoUrl;
            this.result = result;
        }

        @Override
        public void onFinish() {
            Log.d(TAG, "onFinish: ");
            dispose();
            this.activity.getEventSink().endOfStream();
            String videoThumbnail = getLocalVideoThumbnail(this.activity.getActivity(), this.videoUrl);
            result.success(new ArrayList<String>() {{
                add(videoUrl);
                add(videoThumbnail);
            }});
        }

        @Override
        public void onProgress(int progress, long progressTime) {
            if (progress <= 0 || progress > 100) return;
            this.activity.getEventSink().success(String.valueOf(progress));
            Log.d(TAG, "onProgress: " + progress);
        }

        @Override
        public void onCancel() {
            Log.d(TAG, "onCancel: ");
        }

        @Override
        public void onError(String message) {
            Log.d(TAG, "onError: " + message);
        }


    }
}