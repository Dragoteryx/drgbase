import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { ClassComponent } from './class/class.component';
import { MethodComponent } from './class/method/method.component';
import { UnknownComponent } from './unknown/unknown.component';

const routes: Routes = [
  {path: "", component: HomeComponent},
  {path: ":class", component: ClassComponent},
  {path: ":class/:method", component: MethodComponent},
  {path: "**", component: UnknownComponent}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
