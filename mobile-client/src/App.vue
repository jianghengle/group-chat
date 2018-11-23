 <template>
    <root>
      <app-navigation></app-navigation>
    </root>
</template>


<script>
import React from "react";
import { StackNavigator, DrawerNavigator } from "vue-native-router";
import { Root } from "native-base";
import HomeScreen from "./components/Home.vue";
import SideBarScreen from "./components/Sidebar.vue";
import PublicGroupsScreen from "./components/PublicGroups.vue";

const Drawer = DrawerNavigator(
  {
    Home: { screen: HomeScreen },
    PublicGroups: { screen: PublicGroupsScreen },
  },
  {
    initialRouteName: "Home",
    contentOptions: {
      activeTintColor: "#e91e63"
    },
    contentComponent: props => {
      //console.log("props inside contentComponent", props);
      return <SideBarScreen {...props} />;
    }
  }
);

const AppNavigation = StackNavigator(
  {
    Drawer: { screen: Drawer },
  },
  {
    initialRouteName: "Drawer",
    headerMode: "none"
  }
);
export default {
  components: { Root, AppNavigation }
};
</script> 

