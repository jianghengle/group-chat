<template>
  <div>
    <div class="seperator-container has-text-centered" v-if="!isContinued">
      <div class="new-message-label" v-if="isNewChat">new messages</div>
      <hr class="hr chat-seperator" :style="{'background-color': seperatorColor}"></hr>
      <div class="new-day-label" v-if="isNewDay">{{isNewDay}}</div>
    </div>

    <article class="media" :id="'chat-'+chat1.id">
      <figure class="media-left">
        <p class="image is-32x32">
          <img v-if="!isContinued" src="https://bulma.io/images/placeholders/128x128.png">
        </p>
      </figure>
      <div class="media-content">
        <div class="content">
          <p>
            <span v-if="!isContinued"><strong>{{chat1.user.fullName}}</strong> <small>@{{chat1.timeLabel}}</small><br></span>
            <span class="chat-message">{{chat1.message}}</span><br>
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
    groupId () {
      return this.$route.params.groupId
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
      if(this.isNewDay)
        return false
      if(!this.chat0)
        return false
      if(this.chat0.userId != this.chat1.userId)
        return false
      return this.chat1.timestamp - this.chat0.timestamp < 60000
    },
    seperatorColor () {
      if(this.isNewChat)
        return '#ff3860'
      if (this.isNewDay)
        return '#363636'
      return '#dbdbdb'
    },
  },
  methods: {
    openImageModal (source) {
      this.$store.commit('modals/openImageModal', source)
    },
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
}

.chat-video {
  max-width: 90%;
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
  margin-bottom: 15px;
  font-size: 12px;
  font-weight: bold;
  background-color: white;
  color: #ff3860;
  text-align: center;
  border: 1px solid #ff3860;
  border-radius: 5px;
}

</style>
