<template>
  <div class="modal" :class="{'is-active': opened}">
    <div class="modal-background"></div>
    <div id="image-modal-image-container" class="modal-content has-text-centered" :style="{'width': modalSize, 'height': modalSize}">
      <img id="image-modal-image" :src="source" alt="" @load="adjustImage" :style="{'width': width, 'height': height}">
    </div>
    <button class="modal-close is-large" aria-label="close" @click="close"></button>
  </div>
</template>

<script>
export default {
  name: 'image-modal',
  data () {
    return {
      width: 'auto',
      height: 'auto'
    }
  },
  computed: {
    opened () {
      return this.$store.state.modals.imageModal.opened
    },
    source () {
      return this.$store.state.modals.imageModal.source
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    modalSize () {
      return this.isMobile ? '100%' : '80%'
    }
  },
  methods: {
    adjustImage () {
      var container = document.getElementById('image-modal-image-container')
      var containerHeight = container.offsetHeight
      var containerWidth = container.offsetWidth
      var image = document.getElementById('image-modal-image')
      var imageHeight = image.height
      var imageWidth = image.width

      var height = containerWidth / imageWidth * imageHeight
      if(height > containerHeight) {
        this.height = '100%'
        this.width = 'auto'
      }else{
        this.height = 'auto'
        this.width = '100%'
      }
    },
    close(){
      this.$store.commit('modals/closeImageModal')
    }
  },
}
</script>

<style lang="scss" scoped>


</style>