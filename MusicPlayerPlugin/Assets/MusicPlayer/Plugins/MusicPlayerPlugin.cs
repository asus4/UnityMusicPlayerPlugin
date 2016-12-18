using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace MusicPlayer
{
    [Serializable]
    public class Info
    {
        public string title;
        public string artist;
        public string album;
        public float duration;
        public float currentTime;
    }

    public class MusicPlayerPlugin : MonoBehaviour
    {
        public Info info = new Info();
        public event Action<Info> OnPlayingItemChanged;

        public void Load()
        {
            _unityMusicPlayer_load();
        }

        public void Play()
        {
            _unityMusicPlayer_play();
        }

        /// <summary>
        /// Invoked from native code
        /// </summary>
        /// <param name="json"></param>
        public void OnItemChanged(string json)
        {
            info = JsonUtility.FromJson<Info>(json);
            if (OnPlayingItemChanged != null)
            {
                OnPlayingItemChanged(info);
            }
        }

        public float CurrentTime
        {
            get
            {
                info.currentTime = (float) _unityMusicPlayer_currentTime();
                return info.currentTime;
            }
        }

        #region Singleton

        static MusicPlayerPlugin _instance;
        public static MusicPlayerPlugin Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = GameObject.FindObjectOfType<MusicPlayerPlugin>();
                    if (_instance == null)
                    {
                        var go = new GameObject("MusicPlayerPlugin");
                        _instance = go.AddComponent<MusicPlayerPlugin>();
                        DontDestroyOnLoad(go);
                    }
                }

                return _instance;
            }
        }
        #endregion // Singleton


#if UNITY_IPHONE && !UNITY_EDITOR
        [DllImport("__Internal")]
        private static extern void _unityMusicPlayer_load();
        [DllImport("__Internal")]
        private static extern void _unityMusicPlayer_play();
        [DllImport("__Internal")]
        private static extern double _unityMusicPlayer_currentTime();
#else
        private static void _unityMusicPlayer_load() { }

        private static void _unityMusicPlayer_play() { }

        private static double _unityMusicPlayer_currentTime() { return 0; }
#endif
    }
}