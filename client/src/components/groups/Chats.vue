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


      <div class="chats">
        <div v-for="(c, i) in chats">
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
                  <strong>{{c.user.firstName + ' ' + c.user.lastName}}</strong> <small>@{{c.timeLabel}}</small>
                  <br>
                  {{c.message}}
                  <br>
                  <span v-if="c.downloadLink">
                    <img v-if="c.fileType=='image'" :src="c.downloadLink"/>
                    <video v-if="c.fileType=='video'" class="video" controls>
                      <source :src="c.downloadLink">
                      Your browser does not support the video tag.
                    </video>
                    <iframe v-if="c.fileType=='other'" :style="{'width': '100%', 'height': isMobile ? '500px' : '600px'}" :src="'https://docs.google.com/gview?url=' + c.downloadLink + '&embedded=true'"></iframe>
                    Download the attachment: <a :href="c.downloadLink" :download="c.filename">{{c.filename}}</a>
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
  props: ['group'],
  data () {
    return {
      waiting: false,
      error: '',
      message: ''
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
      return this.isMobile ? "5px 10px 5px 10px" : "10px 15px 15px 15px"
    },
    chatsContainerTop () {
      return this.isMobile ? "100px" : "145px"
    },
    chatsContainerBottom () {
      return this.isMobile ? "45px" : "43px"
    },
    chats () {
      return this.group.chats
    }
  },
  watch: {
    groupId: function (val) {
      if(!this.group.chats) {
        this.getChats()
      }
    },
    chats: function (val) {
      if(!val)
        return
      var lastChat = val[val.length-1]
      this.$nextTick(function(){
        var elmnt = document.getElementById("chat-"+lastChat.id)
        if(elmnt)
          elmnt.scrollIntoView({ behavior: 'smooth'})
      })
    }
  },
  methods: {
    getChats () {
      this.waiting = true
      this.$http.get(xHTTPx + '/get_group_chats/' + this.groupId).then(response => {
        var resp = response.body
        var userMap = {}
        resp[1].forEach(function(u){
          userMap[u.id] = u
        })
        var chats = resp[0].map(function(c){
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
        }).sort(function(a, b){
          return a.timestamp - b.timestamp
        })
        this.$store.commit('groups/setGroupChats', {groupId: this.groupId, chats: chats})
        this.waiting = false
      }, response => {
        this.error = 'failed to load chats'
        this.waiting = false
      })
    },
    sendMessage () {
      if(!this.message.trim())
        return
      this.$http.post(xHTTPx + '/add_group_chat/' + this.groupId, {message: this.message.trim()}).then(response => {
        this.message = ''
      })
    },
    openUploadModal () {
      this.$store.commit('modals/openUploadFileModal', this.message)
    },
  },
  mounted () {
    if(!this.group.chats) {
      this.getChats()
    }
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
  top: 200px;
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

</style>
