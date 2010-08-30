#! /usr/bin/env bash

[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

if [[ -z ${RUBY_RUNTIME} ]]; then
  RUBY_RUNTIME=1.8.7
fi

if [[ -n "${JOB_NAME}" ]] ; then
  GEMSET=`echo ${JOB_NAME} | sed "s/ /_/g"`
else
  GEMSET=easy_multipart
fi

if [[ -z "$(rvm list | grep $TARGETRUBY)" ]] ; then
    rvm install ${RUBY_RUNTIME} -C --with-iconv-dir=/usr/local
fi

rvm use ${RUBY_RUNTIME} && \
  rvm --force gemset delete $GEMSET && \
  rvm gemset create $GEMSET && \
  rvm gemset use $GEMSET && \
  gem install rails --version "2.3.8" --no-ri --no-rdoc && \
  rake -t test
