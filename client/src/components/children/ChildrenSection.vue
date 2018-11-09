<template>
  <div>
    <div class="is-size-4 has-text-weight-bold section-header">
      My Children
      <a class="button is-text" @click="openAddChildModal">
        <span class="icon is-small">
          <v-icon name="plus-circle"/>
        </span>
      </a>
    </div>
    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon fa-spin"></v-icon>
    </div>
    <div v-else>
      <div v-if="error" class="notification is-danger login-text">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>
      <div v-if="!children.length">You have not setup or be involved by any child yet.</div>
      <div v-else class="columns is-multiline">
        <div v-for="c in children" class="column is-half">
          <div class="box clickable" @click="viewChild(c.childId)">
            <article class="media">
              <div class="media-left">
                <figure class="image is-64x64">
                  <img src="https://bulma.io/images/placeholders/128x128.png" alt="Image">
                </figure>
              </div>
              <div class="media-content">
                <div class="content">
                  <p>
                    <strong>{{c.child.firstName + ' ' + c.child.lastName}}</strong><br />
                    <small>{{c.relation}}</small>
                  </p>
                </div>
              </div>
            </article>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'children-section',
  data () {
    return {
      waiting: false,
      error: ''
    }
  },
  computed: {
    children () {
      return this.$store.state.children.children
    }
  },
  methods: {
    viewChild (childId) {
      this.$router.push('/children/' + childId)
    },
    openAddChildModal () {
      this.$store.commit('modals/openAddChildModal')  
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.section-header {
  margin-bottom: 10px;
}
</style>
