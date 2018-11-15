<template>
  <div>

    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon fa-spin"></v-icon>
    </div>
    
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div class="chats-container" :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px', 'padding': padding, 'top': chatsContainerTop, 'bottom': chatsContainerBottom}">
      <div class="has-text-centered" v-if="oldestTimestamp">
        <a class="button is-text load-more-button has-text-grey" @click="loadOldChats" v-if="!loadedAll">
          <v-icon name="angle-double-up"></v-icon>
        </a>
        <a class="button is-white load-more-button has-text-grey" v-else>
          <small>Got the oldest point ...</small>
        </a>
      </div>

      <div class="chats">
        <div v-for="(c, i) in chatsAsc">
          <hr v-if="i != 0" class="hr chat-seperator">
          <article class="media" :id="'chat-'+c.id">
            <figure class="media-left">
              <p class="image is-32x32">
                <img src="https://bulma.io/images/placeholders/128x128.png">
              </p>
            </figure>
            <div class="media-content">
              <div class="content">
                <p>
                  <strong>{{c.user.fullName}}</strong> <small>@{{c.timeLabel}}</small><br>
                  <span class="chat-message">{{c.message}}</span><br>
                  <span v-if="c.downloadLink">
                    <span v-if="c.fileType=='image'"><img class="chat-image" :src="c.downloadLink"/></span>
                    <span>
                      <video v-if="c.fileType=='video'" class="chat-video" controls>
                        <source :src="c.downloadLink">
                        Your browser does not support the video tag.
                      </video>
                    </span>
                    <span v-if="c.fileType=='other'">
                      <iframe :style="{'width': '90%', 'height': isMobile ? '300px' : '600px'}" :src="'https://docs.google.com/gview?url=' + c.downloadLink + '&embedded=true'"></iframe>
                    </span>
                    <span><br/>Download the attachment: <a :href="c.downloadLink" :download="c.filename">{{c.filename}}</a></span>
                  </span>
                </p>
              </div>
            </div>
          </article>
        </div>
      </div>
    </div>
        
    <div class="input-container" :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px', 'padding': padding}">
      <div class="field">
        <p class="control has-icons-left">
          <input class="input" type="text" placeholder="Message" v-model="message" @keyup.enter="sendMessage">
          <span class="icon is-small is-left clickable plus-button" @click="openUploadModal">
            <v-icon name="plus"></v-icon>
          </span>
        </p>
      </div>
    </div>
  </div>
</template>

<script>
import DateForm from 'dateformat'



export default {
  name: 'chats',
  data () {
    return {
      waiting: false,
      error: '',
      message: '',
      loadedAll: false
    }
  },
  computed: {
    userId () {
      return this.$store.state.user.userId
    },
    groupId () {
      return this.$route.params.groupId
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    mainContainerLeft () {
      return this.$store.state.ui.mainContainerLeft
    },
    mainContainerWidth () {
      return this.$store.state.ui.mainContainerInnerWidth
    },
    padding () {
      return this.isMobile ? "5px 6px 5px 6px" : "10px 15px 15px 15px"
    },
    chatsContainerTop () {
      return this.isMobile ? "40px" : "50px"
    },
    chatsContainerBottom () {
      return this.isMobile ? "45px" : "43px"
    },
    chatsDesc () {
      return this.$store.state.groups.chats[this.groupId]
    },
    chatsAsc () {
      if(this.chatsDesc){
        return this.chatsDesc.slice().reverse()
      }
      return []
    },
    latestTimestamp () {
      if(this.chatsDesc && this.chatsDesc.length){
        return this.chatsDesc[0].timestamp
      }
      return null
    },
    oldestTimestamp () {
      if(this.chatsDesc && this.chatsDesc.length){
        return this.chatsDesc[this.chatsDesc.length - 1].timestamp
      }
      return null
    },
    group () {
      return this.$store.state.groups.groups[this.groupId]
    },
    groupTimestamp () {
      if(this.group){
        return this.group.timestamp
      }
      return null
    }
  },
  watch: {
    groupId: function (val) {
      this.getChats()
    },
    groupTimestamp: function (val) {
      if(!val)
        return
      this.getChats()
    },
    chatsDesc: function (val) {
      console.log(val)
      // if(!val)
      //   return
      // var lastChat = val[val.length-1]
      // this.$nextTick(function(){
      //   var elmnt = document.getElementById("chat-"+lastChat.id)
      //   if(elmnt)
      //     elmnt.scrollIntoView({ behavior: 'smooth'})
      // })
    }
  },
  methods: {
    getChats () {
      var url = xHTTPx + '/get_latest_chats/' + this.groupId
      if(this.latestTimestamp){
        url = xHTTPx + '/get_chats_since/' + this.groupId + '/' + this.latestTimestamp
      }
      this.waiting = true
      this.$http.get(url).then(response => {
        var resp = response.body
        var chats = this.buildChats(resp[0], resp[1])
        this.$store.commit('groups/pushGroupChats', {groupId: this.groupId, chats: chats})
        this.waiting = false
        this.error = ''
      }, response => {
        this.error = 'failed to load chats'
        this.waiting = false
      })
    },
    buildChats (chats, users) {
      var userMap = {}
      users.forEach(function(u){
        userMap[u.id] = u
      })
      return chats.map(function(c){
        c.user = userMap[c.userId]
        var d = new Date(c.timestamp)
        c.timeLabel = DateForm(d, 'h:MM TT mmm d')
        if(c.attachmentKey && c.filename){
          c.downloadLink = xHTTPx + /download_attachment/ + c.attachmentKey
          var ext = c.filename.includes('.') ? c.filename.split('.').pop().toLowerCase() : ''
          var imageExts = ['png', 'jpg', 'jpeg', 'gif', 'bmp']
          var videoExts = ['mp4', 'webm', 'ogg']
          if(imageExts.includes(ext)){
            c.fileType = 'image'
          }else if(videoExts.includes(ext)){
            c.fileType = 'video'
          }else{
            c.fileType = 'other'
          }
        }
        return c
      })
    },
    sendMessage () {
      if(!this.message.trim())
        return
      this.$http.post(xHTTPx + '/add_chat/' + this.groupId, {message: this.message.trim()}).then(response => {
        var resp = response.body
        var chats = this.buildChats ([resp[0]], [resp[1]])
        this.$store.commit('groups/pushGroupChats', {groupId: this.groupId, chats: chats})
        this.message = ''
      },response => {
        this.error = 'Failed to send message!'
      })
    },
    openUploadModal () {
      this.$store.commit('modals/openUploadFileModal', this.message)
    },
    loadOldChats () {
      var url = xHTTPx + '/get_chats_before/' + this.groupId + '/' + this.oldestTimestamp
      this.waiting = true
      this.$http.get(url).then(response => {
        var resp = response.body
        var chats = this.buildChats(resp[0], resp[1])
        if(chats.length < 20){
          this.loadedAll = true
        }
        this.$store.commit('groups/prependGroupChats', {groupId: this.groupId, chats: chats})
        this.waiting = false
        this.error = ''
      }, response => {
        this.error = 'failed to load chats'
        this.waiting = false
      })
    }
  },
  mounted () {
    this.getChats()
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.input-container {
  position: fixed;
  bottom: 0px;
}

.chats-container {
  position: fixed;
  top: 50px;
  bottom: 100px;
  overflow: auto;
}

.chat-seperator {
  margin-top: 15px;
  margin-bottom: 15px;
}

.plus-button {
  pointer-events: all!important;
}

.chat-message {
  white-space: pre-line;
}

.chat-image {
  max-width: 90%;
}

.chat-video {
  max-width: 90%;
}

.load-more-button {
  padding-top: 0px;
  padding-bottom: 0px;
  height: 20px;
}
</style>
