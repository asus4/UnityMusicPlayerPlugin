using UnityEngine;
using UnityEngine.UI;

namespace MusicPlayer
{
    public class Sample : MonoBehaviour
    {
        public Text infoLabel;

        void OnEnable()
        {
            MusicPlayerPlugin.Instance.OnPlayingItemChanged += OnPlayingItemChanged;
            MusicPlayerPlugin.Instance.OnStateChanged += OnStateChanged;
        }


        void OnDisable()
        {
            MusicPlayerPlugin.Instance.OnPlayingItemChanged -= OnPlayingItemChanged;
            MusicPlayerPlugin.Instance.OnStateChanged -= OnStateChanged;
        }

        void Update()
        {
            var player = MusicPlayerPlugin.Instance;
            var info = player.info;
            double currentTime = player.CurrentTime;

            infoLabel.text = string.Format(@"Info
state:{0}
title:{1}
artist:{2}
album:{3}
duration:{4}
current time:{5}",
player.State, info.title, info.artist, info.album, info.duration, currentTime);
        }

        void OnPlayingItemChanged(MusicPlayer.Info info)
        {
            Debug.Log(info);
        }

        void OnStateChanged(MusicPlayer.PlaybackState state)
        {
            Debug.Log(state);
        }

        public void OnPlay()
        {
            Debug.Log("OnPlay");
            MusicPlayerPlugin.Instance.Play();
        }

        public void OnLoad()
        {
            Debug.Log("OnLoad");
            MusicPlayerPlugin.Instance.Load();
        }
    }
}