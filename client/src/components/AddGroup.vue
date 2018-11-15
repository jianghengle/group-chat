<template>
  <div>
    <div class="common-header level is-mobile"
      :class="{'mobile-header': isMobile, 'desktop-header': !isMobile}"
      :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px'}">
      <div class="level-left">
        <a class="level-item" :class="{'has-text-grey': showSidebar, 'has-text-grey-light': !showSidebar}"
          @click="toggleSidebar">
          <span class="icon">
            <v-icon name="ellipsis-v"/>
          </span>
        </a>
        <div class="has-text-weight-bold level-item" :class="{'is-size-4': !isMobile, 'is-size-5': isMobile}">
          Add Group
        </div>
      </div>
    </div>

    <div :class="{'mobile-body': isMobile, 'desktop-body': !isMobile}">
      <div class="has-text-centered" v-if="waiting">
        <v-icon name="spinner" class="icon fa-spin"></v-icon>
      </div>
      
      <div v-if="error" class="notification is-danger">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>

      <div class="field">
        <label class="label">Name</label>
        <p class="control">
          <input class="input" type="text" v-model="name">
        </p>
      </div>

      <div class="field">
        <label class="label">Description</label>
        <div class="control">
          <textarea class="textarea" placeholder="Description" v-model="description"></textarea>
        </div>
      </div>

      <div class="field">
        <label class="label">Status</label>
        <div class="control">
          <div class="select">
            <select v-model="status">
              <option>public</option>
              <option>private</option>
            </select>
          </div>
        </div>
      </div>

      <div class="field is-grouped">
        <div class="control">
          <button class="button is-link" :disabled="!name.trim()" :class="{'loading': waiting}" @click="addGroup">Add Group</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'add-group',
  data () {
    return {
      waiting: false,
      error: '',
      name: '',
      description: '',
      status: 'public',
    }
  },
  computed: {
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    mainContainerLeft () {
      return this.$store.state.ui.mainContainerLeft
    },
    mainContainerWidth () {
      return this.$store.state.ui.mainContainerInnerWidth
    },
    showSidebar () {
      return this.$store.state.ui.showSidebar
    }
  },
  methods: {
    addGroup () {
      if(!this.name.trim()) return
      this.waiting = true
      var message = {name: this.name.trim(), category: 'group', description: this.description, status: this.status}
      this.$http.post(xHTTPx + '/add_group', message).then(response => {
        this.waiting= false
        var group = response.body
        this.$store.commit('groups/updateGroup', group)
        this.$router.push('/group/' + group.id)
      }, response => {
        this.error = 'Failed to add group!'
        this.waiting= false
      })
    },
    toggleSidebar () {
      this.$store.commit('ui/toggleSidebar')
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.desktop-body {
  margin-top: 50px;
  padding: 20px;
}

.mobile-body {
  margin-top: 40px;
  padding: 10px;
}

</style>
