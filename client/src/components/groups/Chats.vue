<template>
  <div>

    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon fa-spin"></v-icon>
    </div>
    
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>

    <div class="chats-container" :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px', 'padding': chatContainerPadding, 'top': chatsContainerTop, 'bottom': chatsContainerBottom}">
      <div class="has-text-centered" v-if="oldestTimestamp">
        <a class="button is-white load-more-button has-text-grey is-rounded" @click="loadOldChats" v-if="!historyLoaded">
          <small>Load more</small>
        </a>
        <a class="button is-white load-more-button has-text-grey is-rounded" v-else>
          <small>Got the oldest point</small>
        </a>
      </div>

      <div class="chats">
        <div v-for="(c, i) in chatsAsc">
          <chat :chat0="chatsAsc[i-1]" :chat1="chatsAsc[i]"></chat>
        </div>
      </div>

    </div>
        
    <div class="input-container" :style="{'left': mainContainerLeft+'px', 'width': mainContainerInnerWidth+'px', 'padding': inputContainerPadding}">
      <div class="field">
        <p class="control has-icons-left">
          <textarea id="chat-input-textarea" class="textarea my-text-input" placeholder="Message" v-model="message" @keyup.enter="sendMessage"></textarea>
          <span class="icon is-small is-left clickable plus-button has-text-grey-light" @click="openUploadModal">
            <v-icon name="plus"></v-icon>
          </span>
        </p>
      </div>
    </div>
  </div>
</template>

<script>
import DateForm from 'dateformat'
import Chat from './Chat'


export default {
  name: 'chats',
  components: {
    Chat
  },
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
    mainContainerInnerWidth () {
      return this.$store.state.ui.mainContainerInnerWidth
    },
    mainContainerWidth () {
      return this.$store.state.ui.mainContainerWidth
    },
    chatContainerPadding () {
      var extra = this.mainContainerWidth - this.mainContainerInnerWidth
      var paddingRight = this.isMobile ? (6 + extra) : (15 + extra)
      var mobilePadding = "5px " + (6 + extra) + "px 5px 6px"
      var desktopPadding = "10px " + (15 + extra) + "px 15px 15px"
      return this.isMobile ? mobilePadding : desktopPadding
    },
    inputContainerPadding () {
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
    },
    historyLoaded () {
      return this.$store.state.groups.historyLoaded[this.groupId]
    },
  },
  watch: {
    groupId: function (val) {
      this.$store.commit('groups/setLastTimestamp', {groupId: this.groupId, timestamp: this.latestTimestamp})
      this.getChats()
    },
    groupTimestamp: function (val) {
      if(!val)
        return
      this.getChats()
    },
    message: function (val) {
      var el = document.getElementById('chat-input-textarea')
      el.style.height = "1px"
      this.$nextTick(function(){
        if(el.scrollHeight <= 34){
          el.style.height = "2.25em"
        }else{
          el.style.height = (10 + el.scrollHeight) + "px"
        }
      })
    },
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
        if(chats.length && chats[0].timestamp > this.latestTimestamp){
          if(this.latestTimestamp){
            this.$store.commit('groups/pushGroupChats', {groupId: this.groupId, chats: chats})
            this.$nextTick(this.scrollToLatest)
          }else{
            this.$store.commit('groups/pushGroupChats', {groupId: this.groupId, chats: chats})
            setTimeout(this.scrollToLatest, 1000)
          }
        }
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
        c.timeLabel = DateForm(d, 'h:MM TT')
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
        this.$nextTick(function(){
          this.$store.commit('groups/setLastTimestamp', {groupId: this.groupId, timestamp: this.latestTimestamp})
          this.scrollToLatest()
        })
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
        if(chats.length < 100){
          this.$store.commit('groups/setHistoryLoaded', this.groupId)
        }
        this.$store.commit('groups/prependGroupChats', {groupId: this.groupId, chats: chats})
        this.waiting = false
        this.error = ''
      }, response => {
        this.error = 'failed to load chats'
        this.waiting = false
      })
    },
    scrollToLatest () {
      var latestChat = this.chatsDesc[0]
      var el = document.getElementById("chat-"+latestChat.id)
      if(el){
        el.scrollIntoView({ behavior: 'smooth'})
      }
    },
  },
  mounted () {
    this.$store.commit('groups/setLastTimestamp', {groupId: this.groupId, timestamp: this.latestTimestamp})
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

.plus-button {
  pointer-events: all!important;
}

.load-more-button {
  padding-top: 0px;
  padding-bottom: 0px;
  height: 20px;
}

.my-text-input {
  height: 2.25em;
  min-height: 0px;
  padding-left: 2.25em;
  padding-top: calc(0.375em - 1px);
  padding-bottom: calc(0.375em - 1px);
}
</style>
