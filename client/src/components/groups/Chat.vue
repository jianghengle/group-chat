<template>
  <div>
    <div class="seperator-container has-text-centered" v-if="!isContinued">
      <div class="new-message-label" v-if="isNewChat">new messages</div>
      <hr class="hr chat-seperator" :style="{'background-color': seperatorColor, 'margin-top': seperatorMargin, 'margin-bottom': seperatorMargin}"></hr>
      <div class="new-day-label" v-if="isNewDay">{{isNewDay}}</div>
    </div>

    <article class="media chat" :id="'chat-'+chat1.id">
      <div class="forward-dropdown">
        <div class="dropdown is-right is-hoverable">
          <div class="dropdown-trigger">
            <button class="button forward-button" aria-haspopup="true" aria-controls="dropdown-menu">
              <span class="icon is-small">
                <v-icon name="share"></v-icon>
              </span>
            </button>
          </div>
          <div class="dropdown-menu forward-menu" id="dropdown-menu" role="menu">
            <div class="dropdown-content">
              <a class="dropdown-item forward-item" v-for="g in groups" @click="forwardChat(chat1, g)">
                {{g.name}}
              </a>
              <hr class="dropdown-divider" v-if="groups.length && conversations.length">
              <a class="dropdown-item forward-item" v-for="c in conversations" @click="forwardChat(chat1, c)">
                {{c.name == '__' ? 'Yourself Only!' : c.name}}
              </a>
            </div>
          </div>
        </div>
      </div>
      <figure class="media-left">
        <p class="image is-32x32">
          <img v-if="!isContinued" src="https://bulma.io/images/placeholders/128x128.png">
          <small class="small-time-label" v-else>{{chat1.timeLabelSmall}}</small>
        </p>
      </figure>
      <div class="media-content">
        <div class="content">
          <p>
            <span v-if="!isContinued">
              <strong :class="{'clickable': group.category!='conversation' && chat1.user.id!=userId}" @click="openDirectConversationModal(chat1.user)">{{chat1.user.fullName}}</strong>
              <small>{{chat1.timeLabel}}</small><br/>
            </span>
            <span v-if="chat1.message" class="chat-message" v-html="chat1.htmlMessage"></span><br/>
            <span v-if="chat1.downloadLink">
              <span v-if="chat1.fileType=='image'"><img class="chat-image clickable" :src="chat1.downloadLink" @click="openImageModal(chat1.downloadLink)" /></span>
              <span>
                <video v-if="chat1.fileType=='video'" class="chat-video" controls>
                  <source :src="chat1.downloadLink">
                  Your browser does not support the video tag.
                </video>
              </span>
              <span v-if="chat1.fileType=='other'">
                <iframe :style="{'width': '90%', 'height': isMobile ? '300px' : '600px'}" :src="'https://docs.google.com/gview?url=' + chat1.downloadLink + '&embedded=true'"></iframe>
              </span>
              <span><br/>Download the attachment: <a :href="chat1.downloadLink" :download="chat1.filename">{{chat1.filename}}</a></span>
            </span>
          </p>
        </div>
      </div>
    </article>
  </div>
</template>

<script>
import DateForm from 'dateformat'

export default {
  name: 'chat',
  props: ['chat0', 'chat1'],
  data () {
    return {
      waiting: false,
    }
  },
  computed: {
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    userId () {
      return this.$store.state.user.userId
    },
    groupId () {
      return this.$route.params.groupId
    },
    group () {
      return this.$store.state.groups.groups[this.groupId]
    },
    lastTimestamp () {
      return this.$store.state.groups.lastTimestamps[this.groupId]
    },
    isNewChat () {
      if(!this.lastTimestamp)
        return false
      if(!this.chat0)
        if(this.chat1.timestamp > this.lastTimestamp)
          return true
        else
          return false
      if(this.chat0.timestamp <= this.lastTimestamp && this.chat1.timestamp > this.lastTimestamp)
        return true
      return false
    },
    isNewDay () {
      if(!this.chat0)
        return DateForm(this.chat1.timestamp, 'mmm d')

      var day0 = DateForm(this.chat0.timestamp, 'mmm d')
      var day1 = DateForm(this.chat1.timestamp, 'mmm d')
      if(day0 != day1)
        return day1
      return false
    },
    isContinued () {
      if(this.isNewDay || this.isNewChat)
        return false
      if(!this.chat0)
        return false
      if(this.chat0.userId != this.chat1.userId)
        return false
      return true
    },
    seperatorColor () {
      if(this.isNewChat)
        return '#ff3860'
      if (this.isNewDay)
        return '#363636'
      return 'rgba(0,0,0,0)'
    },
    seperatorMargin () {
      if(this.isNewDay){
        return '15px'
      }
      return '5px'
    },
    groups () {
      var groupId = this.groupId
      return Object.values(this.$store.state.groups.groups).filter(function(g){
        return (g && (g.category != 'conversation') && (g.id != groupId))
      })
    },
    conversations () {
      var groupId = this.groupId
      return Object.values(this.$store.state.groups.groups).filter(function(g){
        return (g && (g.category == 'conversation') && (g.id != groupId))
      }).sort(function(a, b){
        return a.timestamp - b.timestamp
      })
    }
  },
  methods: {
    openImageModal (source) {
      this.$store.commit('modals/openImageModal', source)
    },
    openDirectConversationModal (user) {
      if(this.group.category != 'conversation' && user.id != this.userId)
        this.$store.commit('modals/openDirectConversationModal', user)
    },
    forwardChat (chat, g) {
      var message = {message: chat.message, attachmentKey: chat.attachmentKey, forward: 'yes'}
      this.$http.post(xHTTPx + '/add_chat/' + g.id, message).then(response => {
        var resp = response.body
      },response => {
        this.error = 'Failed to forward message!'
      })
    }
  },
  mounted () {
    
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.chat-seperator {
  margin-top: 15px;
  margin-bottom: 15px;
}

.chat-message {
  white-space: pre-wrap;
}

.chat-image {
  max-width: 90%;
  max-height: 600px;
}

.chat-video {
  max-width: 90%;
  max-height: 600px;
}

.seperator-container {
}

.new-day-label {
  width: 80px;
  margin-left: auto;
  margin-right: auto;
  margin-top: -30px;
  margin-bottom: 15px;
  font-size: 16px;
  font-weight: bold;
  background-color: white; 
  text-align: center;
}

.new-message-label {
  float: right;
  position: relative;
  top: -10px;
  width: 110px;
  margin-bottom: -10px;
  font-size: 12px;
  font-weight: bold;
  background-color: white;
  color: #ff3860;
  text-align: center;
  border: 1px solid #ff3860;
  border-radius: 5px;
}

.chat {
  padding: 2px;
  border-radius: 2px;
  position: relative;
  clear: both;
}

.small-time-label {
  display: none;
  color: hsl(0, 0%, 48%);
}

.forward-dropdown {
  position: absolute;
  right: 0px;
  display: none;

  .forward-button {
    color: hsl(0, 0%, 71%);
    border: none;
    background-color: hsl(0, 0%, 96%);
  }

  .forward-menu {
    min-width: 150px;
    top: 30px;

    .forward-item {
      padding-right: 10px;
    }
  }
}

.chat:hover {
  background-color: hsl(0, 0%, 96%);

  .small-time-label {
    display: inline;
  }

  .forward-dropdown {
    display: block;
  }
}

</style>
