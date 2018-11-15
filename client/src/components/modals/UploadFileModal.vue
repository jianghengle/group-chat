<template>
    <div class="modal"
        :class="{'is-active': opened}">
      <div class="modal-background"></div>
      <div class="modal-card">
        <header class="modal-card-head">
          <p class="modal-card-title">Message Attachment</p>
          <button class="delete" @click="close"></button>
        </header>
        <section class="modal-card-body">
          <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
            {{error}}
          </div>
          <div class="field">
            <label class="label">Message</label>
            <div class="control">
              <textarea class="textarea" placeholder="Message" v-model="message"></textarea>
            </div>
          </div>
          <div class="file">
            <label class="file-label">
              <input class="file-input" type="file" name="resume" @change="onFileChange">
              <span class="file-cta">
                <span class="file-icon">
                  <v-icon name="upload"></v-icon>
                </span>
                <span class="file-label">
                  {{file ? file.name : 'Choose a file…'}}
                </span>
              </span>
            </label>
          </div>
        </section>
        <footer class="modal-card-foot">
          <a class="button is-link" :class="{'is-loading': waiting}" :disabled="!file && !message" @click="uploadFile">Send Message</a>
          <a class="button" @click="close">Cancel</a> 
        </footer>
      </div>
    </div>
</template>

<script>

export default {
  name: 'upload-file-modal',
  data () {
    return {
      error: '',
      waiting: false,
      message: '',
      file: null
    }
  },
  computed: {
    opened () {
      return this.$store.state.modals.uploadFileModal.opened
    },
    groupId () {
      return this.$route.params.groupId
    },
  },
  watch: {
    opened: function (val) {
      if(val){
        this.message = this.$store.state.modals.uploadFileModal.message
        this.file = null
      }
    }
  },
  methods: {
    close () {
      this.$store.commit('modals/closeUploadFileModal')
    },
    uploadFile () {
      if(this.waiting)
        return
      this.waiting = true
      var formData = new FormData()
      formData.append('message', JSON.stringify(this.message))
      if(this.file){
        formData.append('file', this.file)
      }

      this.$http.post(xHTTPx + '/add_chat_with_file/' + this.groupId, formData).then(response => {
        this.waiting = false
        this.error = ''
        this.close()
      }, response => {
        this.error = 'Failed to create file!'
        this.waiting = false
      })
    },
    onFileChange(e) {
      var files = e.target.files || e.dataTransfer.files
      if (!files.length)
        return
      this.file = files[0]
    }
  }
}
</script>

<style lang="scss" scoped>


</style>