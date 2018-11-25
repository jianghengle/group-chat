<template>

  <nb-list-item avatar :style="{marginLeft: 0}">
    <nb-left>
      <nb-thumbnail small :source="logo" :style="{borderRadius: 1}"/>
    </nb-left>
    <nb-body :style="{marginLeft: 8, borderColor: 'transparent'}">
      <nb-text :style="{fontWeight: '700'}">Kumar Pratik  <nb-text :style="{fontWeight: '300'}" note>3:43 pm</nb-text></nb-text>
      <nb-text>To mixup Image with other NativeBase components in a single CardItem, include the content within Body componente</nb-text>
    </nb-body>
  </nb-list-item>

</template>

<script>
import { Dimensions } from "react-native";
import { Alert } from "react-native";
import store from '../store'
import axios from 'axios'
import logo from "../../assets/128x128.png";

const deviceWidth = Dimensions.get("window").width;

export default {
  name: 'chat',
  props: {
    navigation: {
      type: Object
    }
  },
  data: function() {
    return {
      message: '',
      logo,
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
  methods: {
  },
  mounted () {
  
  }
}
</script>

 
<style>

</style>
