import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HomeComponent } from './home/home.component';
import { ClassComponent } from './class/class.component';
import { MethodComponent } from './class/method/method.component';
import { UnknownComponent } from './unknown/unknown.component';

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    ClassComponent,
    MethodComponent,
    UnknownComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
