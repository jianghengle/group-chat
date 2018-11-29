<template>
  <modal animationType="slide" :transparent="false" :visible="opened" :onRequestClose="close">
    <nb-header>
      <nb-left>
      </nb-left>
      <nb-body>
        <nb-title>New Photo</nb-title>
      </nb-body>
      <nb-right>
        <nb-button transparent :onPress="close">
          <nb-text>Close</nb-text>
        </nb-button>
      </nb-right>
    </nb-header>

    <view :style="{ flex: 1, width: 300, height: 500 }">
      <camera ref="camera" :style="{ flex: 1 }" :type="type">
        <view :style="{flex: 1, backgroundColor: 'transparent',flexDirection: 'column'}">
          <touchable-opacity :style="{flex: 2, alignSelf: 'flex-end'}"
            :onPress="() => type = type === cameraConstants.Type.back ? cameraConstants.Type.front : cameraConstants.Type.back">
            <text
              :style="{ fontSize: 18, marginTop: 20, marginRight: 20, color: 'white' }">
              [ Flip ]
            </text>
          </touchable-opacity>
          <touchable-opacity :style="{flex: 2, alignSelf: 'center', justifyContent: 'flex-end'}"
            :onPress="takePicture">
            <text
              :style="{ flex: 0, flexDirection: 'column', alignSelf: 'flex-end', fontSize: 18, marginBottom: 30, color: 'white' }">
              [ Snap ]
            </text>
          </touchable-opacity>
        </view>
      </camera>
    </View>

  </modal>
</template>

<script>
import { Dimensions, Modal } from "react-native";
import { Camera, Permissions } from "expo";

const deviceWidth = Dimensions.get("window").width;
const deviceHeight = Dimensions.get("window").height;

export default {
  name:'photo-modal',
  components: {
    Modal,
    Camera
  },
  data: function() {
    return {
      viewWidth: deviceWidth,
      viewHeight: deviceHeight - 41,
      hasCameraPermission: false,
      type: Camera.Constants.Type.back,
      cameraConstants: Camera.Constants
    }
  },
  props: {
    newPhoto: {
      type: Object
    },
    closeNewPhoto: {
      type: Function
    }
  },
  computed: {
    opened () {
      return this.newPhoto.opened
    },
  },
  methods: {
    close () {
      this.closeNewPhoto()
    },
    takePicture: async function() {
      console.log('here')
      if (this.$refs.camera) {
        let photo = await this.$refs.camera.takePictureAsync();
        console.log(photo.uri);
      }
    },
  },
  mounted () {
    var vm = this
    Permissions.askAsync(Permissions.CAMERA)
     .then(status => {
       this.hasCameraPermission = status.status == "granted" ? true : false;
     }).catch((err)=>{
        console.log(err);
     });
  }
}
</script>

 
<style>

</style>
