<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <my-header :navigation="navigation" />

    <nb-content padder>
      <nb-text>
        group: {{group.name}}
      </nb-text>
    </nb-content>

  </nb-container>
</template>

<script>
import { Alert } from "react-native";
import { Toast } from "native-base";
import store from '../store'
import axios from 'axios'
import MyHeader from './MyHeader'

export default {
  components: {
    MyHeader
  },
  props: {
    navigation: {
      type: Object
    }
  },
  data: function() {
    return {
      
    }
  },
  computed: {
    groupId () {
      return this.navigation.state.params.groupId
    },
    group () {
      return store.state.groups.groups[this.groupId]
    }
  },
  watch: {
    groupId: function (val) {
      console.log('group changed', this.group)
    }
  },
  methods: {
    
  },
  mounted () {
    console.log(this.group)
  }
}
</script>

 
<style>

</style>
